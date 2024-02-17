from os import environ
from twitter.account import Account
from twitter.scraper import Scraper

account = Account(cookies = { "ct0": os.environ['TWITTER_COOKIE_ct0'], "auth_token": os.environ['TWITTER_COOKIE_auth_token'] })
scraper = Scraper(session = account.session)
rooms = ['spaces id values...']
spaces = scraper.spaces(rooms = rooms, audio = True, chat = True)
