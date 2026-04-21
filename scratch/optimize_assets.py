import os
from PIL import Image

def optimize_images(root_dir):
    stories_dir = os.path.join(root_dir, 'assets', 'stories')
    if not os.path.exists(stories_dir):
        print(f"Directory not found: {stories_dir}")
        return

    for story_name in os.listdir(stories_dir):
        story_path = os.path.join(stories_dir, story_name)
        if not os.path.isdir(story_path):
            continue

        images_dir = os.path.join(story_path, 'images')
        if not os.path.exists(images_dir):
            continue

        print(f"Optimizing story: {story_name}")
        for filename in os.listdir(images_dir):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
                file_path = os.path.join(images_dir, filename)
                
                try:
                    with Image.open(file_path) as img:
                        # Convert to RGB if necessary (e.g. for WebP/JPEG)
                        if img.mode in ('RGBA', 'P') and not filename.lower().endswith('.webp'):
                            # Keep alpha if we want, but for stories white background is often fine
                            # Actually WebP supports alpha, so let's just ensure it's in a good mode
                            pass
                        
                        # Resize
                        width, height = img.size
                        if width > 1024:
                            ratio = 1024 / float(width)
                            new_height = int(float(height) * float(ratio))
                            img = img.resize((1024, new_height), Image.Resampling.LANCZOS)
                        
                        # Save as WebP
                        base_name = os.path.splitext(filename)[0]
                        new_filename = f"{base_name}.webp"
                        new_path = os.path.join(images_dir, new_filename)
                        
                        img.save(new_path, 'WEBP', quality=85, method=6)
                        print(f"  Optimized: {filename} -> {new_filename}")
                        
                        # Delete old file if it wasn't already webp
                        if filename.lower() != new_filename.lower():
                            os.remove(file_path)
                except Exception as e:
                    print(f"  Error processing {filename}: {e}")

if __name__ == "__main__":
    current_dir = os.getcwd()
    optimize_images(current_dir)
