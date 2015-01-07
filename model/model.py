from yhat import YhatModel, Yhat
import nltk


bot = nltk.chat.eliza.eliza_chatbot
# bot = nltk.chat.iesha.iesha_chatbot


class ChatBot(YhatModel):
    def execute(self, data):
        text = data['text']
        reply = bot.respond(text)
        return { "reply": reply }

print ChatBot().execute({ "text": "I'm feeling sad." })


yh = Yhat("greg", "fCVZiLJhS95cnxOrsp5e2VSkk0GfypZqeRCntTD1nHA", "http://cloud.yhathq.com/")
print yh.deploy("ChatBot", ChatBot, globals())
