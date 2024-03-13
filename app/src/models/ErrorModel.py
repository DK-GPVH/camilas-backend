class Error():
    
    def __init__(self,message,success):
        self.message = message
        self.success = success

    def to_json(self):
        return{
            'message' : self.message,
            'success' : self.success
        }