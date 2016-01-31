/*  
 *  led1.c - switch -> led kernel module
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h>         //required for GPIO functions
#include <linux/interrupt.h>    // for IRQ code
 
MODULE_LICENSE("GPL");
MODULE_AUTHOR("John Doe");
MODULE_DESCRIPTION("LED Switch driver");
MODULE_VERSION("0.1");
 
static unsigned int gpioLED = 61; //# first led from the right. Check table above.
static unsigned int gpioSW = 69; //# first switch from the right. 
static unsigned int irqNumber;
static bool ledOn = 0;
 
// function prototype for custom irq handler
static irq_handler_t gpio_irq_handler(unsigned int irq, void *dev_id, struct pt_regs *regs);
 
static int __init gpio_init(void) {
        int result = 0;
        if (!gpio_is_valid(gpioLED)) {
                printk(KERN_INFO "GPIO_LED: invalid LED GPIO \n");
                return -ENODEV; // No such device
        }
 
        gpio_request(gpioLED, "sysfs");         // request LED on GPIO61
        gpio_direction_output(gpioLED, ledOn); // set gpio to be in output mode, second parameter will set the value
        gpio_export(gpioLED, false);            // export will make the gpio pin to appear in /sys/class/gpio
        gpio_request(gpioSW, "sysfs");          // set up gpio switch
        gpio_direction_input(gpioSW);            // set switch as input
        gpio_set_debounce(gpioSW, 200);         // debounce with delay of 200ms
        gpio_export(gpioSW, false);             // make it appear in /sys/class/gpio
 
        printk(KERN_INFO "GPIO_LED: switch currently in state %d\n", gpio_get_value(gpioSW));
 
        // GPIO numbers and IRQ numbers are not the same and this function will map them
        irqNumber = gpio_to_irq(gpioSW);
        printk(KERN_INFO "GPIO_LED: switch %d is mapped to IRQ %d\n", gpioSW, irqNumber);
 
        // request an interrupt line
        result = request_irq(irqNumber,                             // interrupt number requested
                        (irq_handler_t) gpio_irq_handler,           // pointer to the handler function
                        IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING, // trigger both on rising and falling signal edge
                        "ledswitch_gpio_handler",                   // used in /proc/interrupts to identify the owner
                        NULL);                                      // *dev_id for shared interrupt lines
        printk(KERN_INFO "GPIO_LED: the interrupt request result is: %d\n", result);
        return result;
}
 
static void __exit gpio_exit(void) {
        printk(KERN_INFO "GPIO_LED: The switch state is currently %d\n", gpio_get_value(gpioSW));
        gpio_set_value(gpioLED, 0);
        gpio_unexport(gpioLED);
        free_irq(irqNumber, NULL);
        gpio_unexport(gpioSW);
        gpio_free(gpioLED);
        gpio_free(gpioSW);
        printk(KERN_INFO "GPIO_LED: Module unloaded\n");
}
 
static irq_handler_t gpio_irq_handler(unsigned int irq, void *dev_id, struct pt_regs *regs) {
        ledOn = gpio_get_value(gpioSW); // invert led state
        gpio_set_value(gpioLED, ledOn);
        return (irq_handler_t) IRQ_HANDLED; // announce that the IRQ has been handled correctly
}
 
module_init(gpio_init);
module_exit(gpio_exit);
