import praw
r = praw.Reddit(user_agent="Mass comment editing script")
r.login("username", "password")
for a in r.user.get_comments(limit=1000):
    a.edit("Replacement text here!")
