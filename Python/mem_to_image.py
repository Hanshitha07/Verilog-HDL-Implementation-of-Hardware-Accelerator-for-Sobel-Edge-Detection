import numpy as np
from PIL import Image
import os

# Configuration matching your project
WIDTH, HEIGHT = 256, 256

def reconstruct_image():
    # Use relative paths tailored to your folder structure
    mem_file_path = os.path.join('..', 'Memory', 'output.mem')
    output_image_path = os.path.join('..', 'Images', 'sobel_output.png')
    
    if not os.path.exists(mem_file_path):
        print(f"[ERROR] Cannot find output.mem at {mem_file_path}")
        return

    pixels = []
    
    # Read hex values from Vivado's output file
    with open(mem_file_path, 'r') as f:
        for line in f:
            clean_line = line.strip().lower()
            
            # Skip empty lines or uninitialized simulation values ('xx', 'zz', etc.)
            if not clean_line or 'x' in clean_line or 'z' in clean_line:
                continue
                
            try:
                pixels.append(int(clean_line, 16))
            except ValueError:
                # Catch-all just in case there's another weird formatting character
                continue
                
    total_expected = WIDTH * HEIGHT
    print(f"Successfully read {len(pixels)} valid pixels from output.mem (skipped simulation artifacts).")

    # Handle padding/truncation due to pipeline delays
    if len(pixels) < total_expected:
        # Pad with black pixels if we are slightly short
        pixels += [0] * (total_expected - len(pixels))
    else:
        # Truncate if we have a few extra cycles at the end
        pixels = pixels[:total_expected]

    # Convert list to a 2D NumPy array and save as an image
    img_array = np.array(pixels, dtype=np.uint8).reshape((HEIGHT, WIDTH))
    img = Image.fromarray(img_array)
    img.save(output_image_path)
    img.show()
    print(f"Success! Edge-detected image saved to: {output_image_path}")

if __name__ == "__main__":
    reconstruct_image()