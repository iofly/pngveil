# pngveil
PNG-based steganography software

pngveil encrypts and hides files (payload file) inside the color space of PNG images (i.e. the container
PNG). To extract the payload data, you will need the original password used to encrypt it.

Its written in Delphi (RAD Studio 10, maybe builds in other versions) and released under the MIT License.

One file can be hidden in a container PNG image. The size of the file that can be hidden in a container PNG image is (((height * width) – 5000) * 0.375) bytes. 
