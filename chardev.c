/*  
*  @file chardev.c 
*/
#include <linux/init.h>           // Macros used to mark up functions e.g. __init __exit
#include <linux/module.h>         // Core header for loading LKMs into the kernel
#include <linux/device.h>         // Header to support the kernel Driver Model
#include <linux/kernel.h>         // Contains types, macros, functions for the kernel
#include <linux/fs.h>             // Header for the Linux file system support
#include <asm/uaccess.h>          // Required for the copy to user function
 
// We need to also define class name and device name, which will result of creating a device that appears in the file system at /sys/class/CLASSNAME/DEVICENAME and /dev/DEVICENAME.
#define  DEVICE_NAME "chardev"    // Constant for the device name 
#define  CLASS_NAME  "lab"        // Name of the device class
 
 
MODULE_LICENSE("GPL");                        /* The license type --  Its purpose is to let the kernel developers know when a non-free module has been inserted into a given kernel. */
MODULE_AUTHOR("John Doe");                    /* The author -- visible when you use modinfo */
MODULE_DESCRIPTION("A simple Linux driver."); /* The description -- see modinfo */
MODULE_VERSION("0.1");                        /* The version of the module */
 
 
static int    majorNumber;                  // Stores the device number -- determined automatically
static char   message[256] = {0};           // Memory for the string that is passed from userspace
static short  size_of_message;              // Used to remember the size of the string stored
static int    openCount = 0;                // Counts the number of times the device is opened
static struct class*  charClass  = NULL;    // The device-driver class struct pointer
static struct device* charDevice = NULL;    // The device-driver device struct pointer
 
// The prototype functions for the character driver -- must come before the struct definition
static int     dev_open(struct inode *, struct file *);
static int     dev_release(struct inode *, struct file *);
static ssize_t dev_read(struct file *, char *, size_t, loff_t *);
static ssize_t dev_write(struct file *, const char *, size_t, loff_t *);
 
/*  Devices are represented as file structure in the kernel. The file_operations structure from
 *  /linux/fs.h lists the callback functions that you wish to associated with your file operations
 *  using a C99 syntax structure. char devices usually implement open, read, write and release calls
 */
static struct file_operations fops =
{
  .open = dev_open,
  .read = dev_read,
  .write = dev_write,
  .release = dev_release,
};
 
// initialization function familiar from the previous task
static int __init chardev_init(void)
{
  // register major number dynamically
  majorNumber = register_chrdev(0, DEVICE_NAME, &fops);
  if(majorNumber<0) {
    printk(KERN_ALERT "failed to register a major number.\n");
    return majorNumber;
  }
  printk(KERN_INFO "registered successfully with major number %d\n", majorNumber);
 
  // register device class
  charClass = class_create(THIS_MODULE, CLASS_NAME);
  if (IS_ERR(charClass)) {
    unregister_chrdev(majorNumber, DEVICE_NAME);
    printk(KERN_ALERT "Failed to register fevice class\n");
    return PTR_ERR(charClass); //return an error on a pointer
  }
 
  // register the device driver
  charDevice = device_create(charClass, NULL, MKDEV(majorNumber, 0), NULL, DEVICE_NAME);
  if (IS_ERR(charDevice)) { // if there was a error, do a cleanup
    class_destroy(charClass);
    unregister_chrdev(majorNumber, DEVICE_NAME);
    printk(KERN_ALERT "failed to create the device\n");
    return PTR_ERR(charDevice);
  }
 
  printk(KERN_INFO "device class created successfully.\n");
  return 0;
}
 
static void __exit chardev_exit(void)
{
  device_destroy(charClass, MKDEV(majorNumber, 0)); // remove the device
  class_unregister(charClass); //unregister device class
  class_destroy(charClass); // remove the device class
  unregister_chrdev(majorNumber, DEVICE_NAME); //unregister the major number
  printk(KERN_INFO "module unloaded.");
}
 
/* Called each time the device file is opened */
static int dev_open(struct inode *inodep, struct file *filep) {
  openCount++;
  printk(KERN_INFO "device has been opened %d times\n", openCount);
  return 0;
}
 
/* Called whenever device is being read from user space */
static ssize_t dev_read(struct file *filep, char *buffer, size_t len, loff_t *offset) {
  int error_count = 0;
  // copy_to_user - sends the buffer string to the user
  error_count = copy_to_user(buffer, message, size_of_message);
  if (error_count==0) {
    printk(KERN_INFO "sent %d characters to the user\n", size_of_message);
    return(size_of_message=0);
    } else {
      printk(KERN_INFO "failed to send %d characters to the user\n", error_count);
      return -EFAULT; //return bad address message (-14)
    }
}
 
/* this function is called whenever the device is being written from user space. */
static ssize_t dev_write(struct file *filep, const char *buffer, size_t len, loff_t *offset) {
  sprintf(message, "%s(%d letters)", buffer, len);  // append received string with its length
  size_of_message = strlen(message);
  printk(KERN_INFO "received %d characters from the user\n", len);
  return len;
}
 
static int dev_release(struct inode *inodep, struct file *filep) {
  printk(KERN_INFO "device successfully closed\n");
  return 0;
}
 
 
module_init(chardev_init);
module_exit(chardev_exit);
