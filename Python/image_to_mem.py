from PIL import Image
import os

# -----------------------------
# Configuration
# -----------------------------
IMAGE_PATH = "../Images/panda.png"
OUTPUT_MEM = "../Memory/input.mem"

# -----------------------------
# Load image
# -----------------------------
img = Image.open(IMAGE_PATH)

# Convert to grayscale
img = img.convert("L")

# Resize only if needed
if img.size != (256, 256):
    img = img.resize((256, 256))

# Create Memory folder if it doesn't exist
os.makedirs("../Memory", exist_ok=True)

# Save grayscale image (optional, for checking)
img.save("../Images/grayscale.png")

# Get pixel data
pixels = list(img.getdata())

# Write pixels to .mem file
with open(OUTPUT_MEM, "w") as f:
    for pixel in pixels:
        f.write(f"{pixel:02X}\n")

print("--------------------------------")
print("Conversion Successful!")
print("Image Size :", img.size)
print("Total Pixels :", len(pixels))
print("Output File :", OUTPUT_MEM)
print("--------------------------------")