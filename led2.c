/*  
 *  led2.c - advanced led kernel module
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h>       //required for GPIO functions
 
#include <linux/kobject.h>    // using kobjects for the sysfs bindings
#include <linux/kthread.h>    // for using kthreads in the led flashing functionality
#include <linux/delay.h>  // msleep() function
 
MODULE_LICENSE("GPL");
MODULE_AUTHOR("John Doe");
MODULE_DESCRIPTION("LED sysfs interface driver");
MODULE_VERSION("0.1");
 
static unsigned int gpioLED = 61;
static bool ledState = 0;
static char ledName[7] = "myled";
static unsigned int period = 1000; // blink period in ms
 
enum modes { OFF, ON, BLINK };      // enum for LED modes
static enum modes mode = ON;        // default mode off
 
// Callback function to display the LED mode
static ssize_t mode_show(struct  kobject *kobj, struct kobj_attribute *attr, char *buf) {
    switch(mode) {
        case OFF:   return sprintf(buf, "off\n"); 
        case ON:    return sprintf(buf, "on\n");
        case BLINK: return sprintf(buf, "blink\n");
        default:    return sprintf(buf, "LKM Error\n"); // shouldn't get here
    }
}
 
// Callback function to stre the LED mode 
static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count) {
    if (strncmp(buf, "on", count-1)==0) { mode = ON; } // compare with fixed number of chars, count-1 needed to exclude \n
    else if (strncmp(buf, "off", count-1)==0) { mode = OFF; }
    else if (strncmp(buf, "blink", count-1)==0)  {mode = BLINK; }
    return count;
}
 
// Callback function to display the LED blinking period
static ssize_t period_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf) {
    return sprintf(buf, "%d\n", period);
}
 
// Callback function to store LED blinking period
static ssize_t period_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count) {
    unsigned int p;
    sscanf(buf, "%du", &p);     // read in the period as an unsigned int
    if ((p>1) && (p<=10000)) {    // validate range
        period = p;
    }
    return p;
}
 
// helper macros to define the name and access levels of the kobj_attributes
// __ATTR(variable name, user rights mode, show function, store function)
static struct kobj_attribute period_attr = __ATTR(period, 0666, period_show, period_store);
static struct kobj_attribute mode_attr = __ATTR(mode, 0666, mode_show, mode_store);
 
// led_attrs is an array of attributes that is used to create the attribute group below
static struct attribute *led_attrs[] = {
    &period_attr.attr,
    &mode_attr.attr,
    NULL,
};
 
static struct attribute_group attr_group = {
    .name = ledName,
    .attrs = led_attrs,
};
 
static struct kobject *led_kobj;    // pointer to the kobject
static struct task_struct *task;    // pointer to the thread task
 
// kthread loop to blink the LED
static int blink(void *arg) {
    while(!kthread_should_stop()) {     //returns true when kthread_stop() is called
        set_current_state(TASK_RUNNING);
        if(mode==BLINK) ledState = !ledState;  // if the mode is blink, then invert LED state
        else if(mode==ON) ledState = true;
        else ledState = false;
        gpio_set_value(gpioLED, ledState); // send the LED state value to the GPIO
        set_current_state(TASK_INTERRUPTIBLE);
        msleep(period/2);       // sleep half of the period (cycle of on+off is one period)
    }
    return 0;
}
 
static int __init gpio_init(void) {
    int result = 0;
 
    // let's create a entry in sysfs (/sys/kernel/lab/myled)
    sprintf(ledName, "myled");
    led_kobj = kobject_create_and_add("lab", kernel_kobj); // kernel_kobj points to /sys/kernel
    if(!led_kobj) {
        printk(KERN_ALERT "GPIO_LED: failed to create kobject\n");
        return -ENOMEM; 
    }
     
    // add attributes to sysfs, for example /sys/kernel/lab/myled/mode
    result = sysfs_create_group(led_kobj, &attr_group);
    if(result) {
        printk(KERN_ALERT "GPIO_LED: failed to create sysfs group\n");
        kobject_put(led_kobj);  // clean up by removing the kobject sysfs entry
        return result;
    }
 
    task = kthread_run(blink, NULL, "LED_blink_thread"); // start LED blinking thread
    if(IS_ERR(task)) {
        printk(KERN_ALERT "GPIO_LED: failed to craete led blinking task\n");
        return PTR_ERR(task);
    }
 
 
    if (!gpio_is_valid(gpioLED)) {
        printk(KERN_INFO "GPIO_LED: invalid LED GPIO \n");
        return -ENODEV; // No such device
    }
 
    gpio_request(gpioLED, "sysfs"); // request LED on GPIO63
    gpio_direction_output(gpioLED, ledState); // set gpio to be in output mode, second parameter will set the value
    gpio_export(gpioLED, false);        // export will make the gpio pin to appear in /sys/class/gpio
                        // second parameter will prevent direction from being changed
 
    return result;
}
 
static void __exit gpio_exit(void) {
    kthread_stop(task);     // stop LED blinking thread
    kobject_put(led_kobj);  // clean the kobject sysfs entry
    gpio_set_value(gpioLED, 0);
    gpio_unexport(gpioLED);
    gpio_free(gpioLED);
    printk(KERN_INFO "GPIO_LED: Module unloaded\n");
}
 
module_init(gpio_init);
module_exit(gpio_exit);
