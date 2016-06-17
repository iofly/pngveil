# pngveil
PNG-based steganography software

pngveil encrypts and hides files (payload file) inside the color space of PNG images (i.e. the container
PNG). To extract the payload data, you will need the original password used to encrypt it.

##Limitations
1. Only one file can be hidden in a container PNG image.

2. The size of the file that can be hidden in a container PNG image is (((height * width) – 5000) *
0.375) bytes. Roughly. Some of this is reserved for metadata like encrypted payload hash and
encrypted payload file name (to help when extracting). The application will warn you if the file
you’re trying to hide is too big.

3. Although hiding a payload file inside the color space of a PNG image will leave the image looking
identical to the naked eye, it may end up increasing the size of the container PNG image by more
than the actual payload file size. The is due to how PNG images are compressed. The PNG
algorithm works best when there are no small differences between pixel colors, making changes
to pixels can degrade the efficiency of the compression.
