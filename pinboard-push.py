#!/usr/bin/env python

import glob
import os
import re
import subprocess
import sys

import requests


LEVELS = 0
TOPICS = []
AUTH_TOKEN = ''
URL = 'https://api.pinboard.in/v1/posts/add'


def sane_string(string):
    """Make the string sane"""
    return re.sub(r'[^.a-zA-Z0-9]', '_', string.strip())

def sane_string_spaces(string):
    """Make the string sane"""
    return re.sub(r'[^ .a-zA-Z0-9]', '-', string.strip())

def set_subtopics(line):
    """Set subtopic"""
    global LEVELS, TOPICS

    current_level = LEVELS
    current_topic = TOPICS[0]

    new_topic = line.lstrip('#').lower()
    new_level = len(line) - len(new_topic)
    new_topic = sane_string(new_topic)

    LEVELS = new_level

    if new_level == current_level:
        TOPICS.pop()
        TOPICS.append(new_topic)
        return

    if new_level > current_level:
        TOPICS.append(new_topic)
        return

    TOPICS = [current_topic, new_topic]


def set_topic(topic):
    """Sets global topics based on headline level"""
    global LEVELS, TOPICS

    LEVELS = 0
    TOPICS = [topic]


def update_pinboard(line):
    """Send the new link up to pinboard"""
    split_line = line.split('(')
    title = sane_string_spaces(split_line[0].lstrip('* '))
    link = split_line[-1].rstrip(') ')

    data = {
        'auth_token': AUTH_TOKEN,
        'url': link,
        'description': title,
        'tags': ' '.join(TOPICS)
    }

    r = requests.get(URL, params=data)
    r.raise_for_status()
    print(data)


def get_auth(site):
    global AUTH_TOKEN
    path = os.path.join(os.getenv('HOME'), 'bin', 'getnetrc')
    user = subprocess.check_output([path, site, 'login'])
    token = subprocess.check_output([path, site])
    AUTH_TOKEN = '{}:{}'.format(
        str(user.strip(), 'utf-8'),
        str(token.strip(), 'utf-8'))


def main():
    get_auth('pinboard.in')
    for fn in glob.glob('*.md'):
        topic = fn[:-3].lower()

        if topic == 'index':
            continue

        set_topic(topic)

        with open(fn) as f:
            lines = f.read()

        front_matter = True
        for line in lines.splitlines():
            if line == '---':
                front_matter = False

            if front_matter:
                continue

            if not line:
                continue

            if line.startswith('#'):
                topics = set_subtopics(line)
                continue

            if '[' in line:
                update_pinboard(line)

if __name__ == '__main__':
    main()
