import twitter
import configparser
import sys

config = configparser.ConfigParser()
config.read('api.ini')

api = twitter.Api(consumer_key=config['OAuth']['consumer_key'],\
                consumer_secret=config['OAuth']['consumer_secret'],\
                access_token_key=config['OAuth']['access_token_key'],\
                access_token_secret=config['OAuth']['access_token_secret'])

if __name__=='__main__':
    api.PostUpdates(sys.argv[1])