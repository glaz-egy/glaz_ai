import twitter
import configparser
import sys
import os
import re

config = configparser.ConfigParser()
config.read('api.ini')

api = twitter.Api(consumer_key=config['OAuth']['consumer_key'],\
                consumer_secret=config['OAuth']['consumer_secret'],\
                access_token_key=config['OAuth']['access_token_key'],\
                access_token_secret=config['OAuth']['access_token_secret'])

def auto_follow():
    try:
        Followers = api.GetFollowers()
        Friends = api.GetFriends()
        for follower in Followers:
            if not follower in Friends:
                api.CreateFriendship(user_id=follower.id)
    except:
        exit(0)

def get_tweet(count=200):
    try:
        if '@' in config['User']['user_id']: UserId = config['User']['user_id'].split('@')
        else: UserId = [config['User']['user_id']]
        statuse = []
        for user in UserId:
            statuse.extend(api.GetUserTimeline(user.strip(), count=count))
        if not os.path.isfile('textdata.txt'):
            with open('textdata.txt', 'w') as f:
                pass
        with open('textdata.txt', 'r', encoding='utf-8') as f:
            ExistData = f.readlines()
        for s in statuse:
            MucthText = re.search(r"@.*\s", s.text)
            if MucthText is None: texts = s.text
            else:
                texts = MucthText.string.replace(" ", "")
                texts = texts.replace("@", "")
            MucthText = re.search(r"http.*", texts)
            texts = texts if MucthText is None else texts.replace(MucthText.group(0), '')
            MucthText = re.search(r"#.*", texts)
            texts = texts if MucthText is None else texts.replace(MucthText.group(0), '')
            if not "RT" in texts and None == s.retweeted_status and re.match(r".*@.*(より|さんから)", texts) is None:
                texts = texts.strip().split('\n')
                for text in texts:
                    if not text == '\n' and not text == '' and re.match(r"\s+", text) is None and not text+'\n' in ExistData:
                        ExistData.append(text)
                        with open('textdata.txt', 'a', encoding='utf-8') as f:
                            f.write(text+'\n')
    except:
        exit(0)
    auto_follow()

if __name__=='__main__':
    get_tweet()