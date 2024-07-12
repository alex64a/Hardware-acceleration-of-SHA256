#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/cdev.h>
#include <linux/kdev_t.h>
#include <linux/uaccess.h>
#include <linux/errno.h>
#include <linux/device.h>

#include <linux/io.h>              //iowrite ioread
#include <linux/slab.h>            //kmalloc kfree
#include <linux/platform_device.h> //platform driver
#include <linux/ioport.h>          //ioremap

#define DRIVER_NAME "sha256"
#define BUFF_SIZE 65
#define OUTPUT_SIZE (256 / 8)
#define HEX_AMOUNT OUTPUT_SIZE * 2 + 1

MODULE_LICENSE("Dual BSD/GPL");

/** @brief Function to pad the inputed message
 *  @param char* buff, @param size_t length
 */
void Pad(char *buff, size_t length);

/** @brief Main function of the SHA256 algorithm
 */
void Hash(void);

/** @brief right rotation
 *  @param uint32_t x number to be rotated right
 *  @param size_t n number of times to rotate x to the right
 */
uint32_t rotr(uint32_t x, size_t n);

/** @brief shift right
 *  @param uint32_t x number to be shifted
 *  @param size_t n number of times to shift x to the right
 */
uint32_t shr(uint32_t x, size_t n);

/** @brief Choose function
 *  @param uint32_t x, @param uint32_t y, @param uint32_t z
 */

uint32_t Ch(uint32_t x, uint32_t y, uint32_t z);

/** @brief Majority function
 *  @param uint32_tx. @param uint32_t y, @param uint32_t z
 */

uint32_t Maj(uint32_t x, uint32_t y, uint32_t z);

/** @brief ep0 function
 *  @param uint32_t x
 */
uint32_t ep0(uint32_t x);

/** @brief ep1 function
 *  @param uint32_t x
 */
uint32_t ep1(uint32_t x);

/** @brief sig0 function
 *  @param uint32_t x
 */
uint32_t sig0(uint32_t x);

/** @brief sig1 function
 *  @param uint32_t x
 */
uint32_t sig1(uint32_t x);

/** @brief swap byte Endian 32 bit
 *  @param uint32_t val
 */
uint32_t swapE32(uint32_t val);

/** @brief swap byte Endian 64 bit
 *  @param uint64_t val
 */
uint64_t swapE64(uint64_t val);

/** @brief function to help with printing hex numbers
 *  @param void* buffer, @param size_t len
 */
void hex(void *buffer, size_t len);

/** @brief function to print the output hash
 */
void printHash(void);

// Variable declarations
uint64_t l;
size_t k;
size_t msgSize;
char *msgPad;
size_t len;
size_t N;
uint32_t v[8];
uint32_t W[64];
uint32_t *M;
uint32_t T1, T2;
int endRead = 0;
int pos = 0;
bool result_ready = 0;
unsigned char hexAmount[HEX_AMOUNT];

// Constants declaration
const int sha256BlockSize = 512;

/** @brief Constants for the SHA256 algorithm
 */
uint32_t K[] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

/** @brief H is the output of the algorithm, it's initial state is
 *        defined according to the algorithm guide.
 */
uint32_t H[] = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19};

struct sha256_info
{
    unsigned long mem_start;
    unsigned long mem_end;
    void __iomem *base_addr;
};

dev_t my_dev_id;
static struct class *my_class;
static struct device *my_device;
static struct cdev *my_cdev;
static struct sha256_info *lp = NULL;

static int sha256_probe(struct platform_device *pdev);
static int sha256_remove(struct platform_device *pdev);
int sha256_open(struct inode *pinode, struct file *pfile);
int sha256_close(struct inode *pinode, struct file *pfile);
ssize_t sha256_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset);
ssize_t sha256_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset);
static int __init sha256_init(void);
static void __exit sha256_exit(void);

struct file_operations my_fops =
    {
        .owner = THIS_MODULE,
        .open = sha256_open,
        .read = sha256_read,
        .write = sha256_write,
        .release = sha256_close,
};

// static struct of_device_id sha256_of_match[] = {
//     {
//         .compatible = "sha256",
//     },
//     {/* end of list */},
// };

static struct platform_driver sha256_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        //  .of_match_table = sha256_of_match,
    },
    .probe = sha256_probe,
    .remove = sha256_remove,
};

// MODULE_DEVICE_TABLE(of, sha256_of_match);

static int sha256_probe(struct platform_device *pdev)
{
    struct resource *r_mem;
    int rc = 0;
    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem)
    {
        printk(KERN_ALERT "Failed to get resource\n");
        return -ENODEV;
    }
    lp = (struct sha256_info *)kmalloc(sizeof(struct sha256_info), GFP_KERNEL);
    if (!lp)
    {
        printk(KERN_ALERT "Could not allocate sha256 device\n");
        return -ENOMEM;
    }

    lp->mem_start = r_mem->start;
    lp->mem_end = r_mem->end;
    // printk(KERN_INFO "Start address:%x \t end address:%x", r_mem->start, r_mem->end);

    if (!request_mem_region(lp->mem_start, lp->mem_end - lp->mem_start + 1, DRIVER_NAME))
    {
        printk(KERN_ALERT "Could not lock memory region at %p\n", (void *)lp->mem_start);
        rc = -EBUSY;
        goto error1;
    }

    lp->base_addr = ioremap(lp->mem_start, lp->mem_end - lp->mem_start + 1);
    if (!lp->base_addr)
    {
        printk(KERN_ALERT "Could not allocate memory\n");
        rc = -EIO;
        goto error2;
    }

    printk(KERN_WARNING "sha256 platform driver registered\n");
    return 0; // ALL OK

error2:
    release_mem_region(lp->mem_start, lp->mem_end - lp->mem_start + 1);
error1:
    return rc;
}

static int sha256_remove(struct platform_device *pdev)
{
    printk(KERN_WARNING "sha256 platform driver removed\n");
    iowrite32(0, lp->base_addr);
    iounmap(lp->base_addr);
    release_mem_region(lp->mem_start, lp->mem_end - lp->mem_start + 1);
    kfree(lp);
    return 0;
}

int sha256_open(struct inode *pinode, struct file *pfile)
{
    printk(KERN_INFO "Succesfully opened sha256\n");
    return 0;
}

int sha256_close(struct inode *pinode, struct file *pfile)
{
    printk(KERN_INFO "Succesfully closed sha256\n");
    return 0;
}

ssize_t sha256_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset)
{
    // squeeze into file
    char buff[BUFF_SIZE];
    int ret, len;

    if (result_ready == 0)
    {
        printk(KERN_ERR "Result not ready ");
        return 0;
    }

    if (endRead)
    {
        endRead = 0;
        pos = 0;
        result_ready = 0;
        return 0;
    }

    if (pos < BUFF_SIZE)
    {
        len = scnprintf(buff, BUFF_SIZE, "%c", hexAmount[pos++]);
        ret = copy_to_user(buffer, buff, HEX_AMOUNT);
    }
    else if (pos == BUFF_SIZE - 1)
    {
        len = scnprintf(buff, BUFF_SIZE, "%c\n", hexAmount[pos++]);
        ret = copy_to_user(buffer, buff, HEX_AMOUNT);
    }
    else if (pos == BUFF_SIZE) // 65
        endRead = 1;

    if (ret)
    {
        return -EFAULT;
    }

    return len;
}

ssize_t sha256_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset)
{
    char *buff;
    size_t len;
    int ret;
    int blockCount;
    result_ready = 0;
    if (length + 1 == sha256BlockSize)
    {
        buff = (unsigned char *)kmalloc(sha256BlockSize + 1, GFP_KERNEL);
        blockCount = 1;
    }
    else
    {
        blockCount = length / sha256BlockSize;
        blockCount++;
        buff = (unsigned char *)kmalloc(blockCount * sha256BlockSize + 1, GFP_KERNEL);
        printk(KERN_INFO "Successfully allocated memory, blockCount: %d", blockCount);
    }

    if (!buff)
        return -EFAULT;

    ret = copy_from_user(buff, buffer, length);
    if (ret)
        return -EFAULT;

    buff[length] = '\0';
    printk(KERN_INFO "Successfully wrote buff: %s", buff);
    len = strlen(buff);

    // Padding and hashing
    Pad(buff, len);
    Hash();
    printHash();

    kfree(buff);

    result_ready = 1;

    return length;
}

static int __init sha256_init(void)
{
    int ret = 0;

    // Initialize array

    ret = alloc_chrdev_region(&my_dev_id, 0, 1, DRIVER_NAME);
    if (ret)
    {
        printk(KERN_ERR "failed to register char device\n");
        return ret;
    }
    printk(KERN_INFO "char device region allocated\n");

    my_class = class_create("sha256_class");
    if (my_class == NULL)
    {
        printk(KERN_ERR "failed to create class\n");
        goto fail_0;
    }
    printk(KERN_INFO "class created\n");

    my_device = device_create(my_class, NULL, my_dev_id, NULL, DRIVER_NAME);
    if (my_device == NULL)
    {
        printk(KERN_ERR "failed to create device\n");
        goto fail_1;
    }
    printk(KERN_INFO "device created\n");

    my_cdev = cdev_alloc();
    my_cdev->ops = &my_fops;
    my_cdev->owner = THIS_MODULE;
    ret = cdev_add(my_cdev, my_dev_id, 1);
    if (ret)
    {
        printk(KERN_ERR "failed to add cdev\n");
        goto fail_2;
    }
    printk(KERN_INFO "cdev added\n");
    printk(KERN_INFO "Hello world from SHA256\n");

    return platform_driver_register(&sha256_driver);

fail_2:
    device_destroy(my_class, my_dev_id);
fail_1:
    class_destroy(my_class);
fail_0:
    unregister_chrdev_region(my_dev_id, 1);
    return -1;
}

static void __exit sha256_exit(void)
{
    platform_driver_unregister(&sha256_driver);
    cdev_del(my_cdev);
    device_destroy(my_class, my_dev_id);
    class_destroy(my_class);
    unregister_chrdev_region(my_dev_id, 1);
    printk(KERN_INFO "Exited SHA256\n");
}

uint32_t rotr(uint32_t x, size_t n) { return (x >> n) | (x << (32 - n)); }

uint32_t shr(uint32_t x, size_t n) { return x >> n; }

uint32_t Ch(uint32_t x, uint32_t y, uint32_t z) { return (x & y) ^ (~x & z); }

uint32_t Maj(uint32_t x, uint32_t y, uint32_t z)
{
    return (x & y) ^ (x & z) ^ (y & z);
}

uint32_t ep0(uint32_t x) { return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22); }

uint32_t ep1(uint32_t x) { return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25); }

uint32_t sig0(uint32_t x) { return rotr(x, 7) ^ rotr(x, 18) ^ shr(x, 3); }

uint32_t sig1(uint32_t x) { return rotr(x, 17) ^ rotr(x, 19) ^ shr(x, 10); }

uint32_t swapE32(uint32_t val)
{
    uint32_t x = val;
    x = (x & 0xffff0000) >> 16 | (x & 0x0000ffff) << 16;
    x = (x & 0xff00ff00) >> 8 | (x & 0x00ff00ff) << 8;
    return x;
}
uint64_t swapE64(uint64_t val)
{
    uint64_t x = val;
    x = (x & 0xffffffff00000000) >> 32 | (x & 0x00000000ffffffff) << 32;
    x = (x & 0xffff0000ffff0000) >> 16 | (x & 0x0000ffff0000ffff) << 16;
    x = (x & 0xff00ff00ff00ff00) >> 8 | (x & 0x00ff00ff00ff00ff) << 8;
    return x;
}

void hex(void *buffer, size_t len)
{
    for (size_t i = 0; i < len; i++)
    {
        pr_info("%02x", ((char *)buffer)[i] & 0xff);
        if (i % 4 == 3)
            pr_info(" ");
    }
}

void printHash()
{
    for (size_t i = 0; i < 8; i++)
    {
        H[i] = swapE32(H[i]);
        hex(&H[i], 4);
    }
    pr_info("\n");
    kfree(msgPad);
}

void Pad(char *msg, size_t len)
{
    l = len * sizeof(char) * 8;
    k = (448 - l - 1) % 512;
    if (k <= 0)
        k += 512;
    msgSize = l + 1 + k + 64;

    msgPad = (char *)kcalloc((msgSize / 8), sizeof(char), GFP_KERNEL);
    memcpy(msgPad, msg, len);
    msgPad[len] = 0x80;
    l = swapE64(l);
    memcpy(msgPad + (msgSize / 8) - 8, &l, 8);
    N = msgSize / 512;

    // 6.2

    M = (uint32_t *)msgPad;

    for (size_t i = 0; i < N * 16; i++)
    {
        M[i] = swapE32(M[i]);
    }
}

void Hash()
{
    // 6.2.2
    for (size_t i = 0; i < N; i++)
    {
        // 1
        for (size_t t = 0; t < 16; t++)
        {
            W[t] = M[i * 16 + t];
        }
        for (size_t t = 16; t < 64; t++)
        {
            W[t] = sig1(W[t - 2]) + W[t - 7] + sig0(W[t - 15]) + W[t - 16];
        }

        // 2
        for (size_t t = 0; t < 8; t++)
        {
            v[t] = H[t];
        }

        // 3
        for (size_t t = 0; t < 64; t++)
        {
            // a=0 b=1 c=2 d=3 e=4 f=5 g=6 h=7
            T1 = v[7] + ep1(v[4]) + Ch(v[4], v[5], v[6]) + K[t] + W[t];
            T2 = ep0(v[0]) + Maj(v[0], v[1], v[2]);

            v[7] = v[6];
            v[6] = v[5];
            v[5] = v[4];
            v[4] = v[3] + T1;
            v[3] = v[2];
            v[2] = v[1];
            v[1] = v[0];
            v[0] = T1 + T2;
        }

        for (size_t t = 0; t < 8; t++)
        {
            H[t] += v[t];
        }
    }
}

module_init(sha256_init);
module_exit(sha256_exit);
