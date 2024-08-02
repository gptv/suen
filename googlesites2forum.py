import requests

# Configuration
DISCOURSE_API_URL = 'https://forum.bdfzer.com'
API_KEY = ''
API_USERNAME = 'suen'  # Your Discourse API username
CATEGORY_ID = 6  # Replace with your target category ID

# Headers for API authentication
headers = {
    'Api-Key': API_KEY,
    'Api-Username': API_USERNAME,
    'Content-Type': 'application/json'
}

# Function to create a Discourse post
def create_discourse_post(title, content):
    url = f"{DISCOURSE_API_URL}/posts.json"
    payload = {
        'title': title,
        'raw': content,
        'category': CATEGORY_ID,
    }
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 200:
        print(f"Post created successfully: {response.json()['topic_id']}")
        return response.json()['topic_id']
    else:
        print(f"Failed to create post: {response.status_code} {response.text}")
        return None

# Function to read links and their annotations from file
def read_annotated_links(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    links_and_titles = []
    for line in lines:
        link, annotation = line.rsplit('  # ', 1)
        title = annotation.strip()
        links_and_titles.append((link.strip(), title))
    
    return links_and_titles

# Path to the file with annotated links
file_path = '/mnt/data/sorted_annotated_links.txt'
links_and_titles = read_annotated_links(file_path)

# Create posts for each link using titles from annotations
for link, title in links_and_titles:
    content = f"Let's discuss the content related to [{title}]({link})."
    create_discourse_post(title, content)