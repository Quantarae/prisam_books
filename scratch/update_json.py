import os
import json

def update_json_extensions(root_dir):
    # Update books.json
    books_path = os.path.join(root_dir, 'assets', 'books.json')
    if os.path.exists(books_path):
        with open(books_path, 'r') as f:
            books = json.load(f)
        for book in books:
            if 'thumbnail' in book:
                book['thumbnail'] = book['thumbnail'].replace('.png', '.webp').replace('.jpg', '.webp').replace('.jpeg', '.webp')
        with open(books_path, 'w') as f:
            json.dump(books, f, indent=2)
        print("Updated books.json")

    # Update story.json files
    stories_dir = os.path.join(root_dir, 'assets', 'stories')
    if os.path.exists(stories_dir):
        for story_name in os.listdir(stories_dir):
            story_path = os.path.join(stories_dir, story_name)
            if not os.path.isdir(story_path):
                continue
            
            manifest_path = os.path.join(story_path, 'story.json')
            if os.path.exists(manifest_path):
                with open(manifest_path, 'r') as f:
                    pages = json.load(f)
                for page in pages:
                    if 'image' in page and page['image']:
                        page['image'] = page['image'].replace('.png', '.webp').replace('.jpg', '.webp').replace('.jpeg', '.webp')
                with open(manifest_path, 'w') as f:
                    json.dump(pages, f, indent=2)
                print(f"Updated {story_name}/story.json")

if __name__ == "__main__":
    current_dir = os.getcwd()
    update_json_extensions(current_dir)
