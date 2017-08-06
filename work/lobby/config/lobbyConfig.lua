local config
config =
{
    server =
    {
    	ip = "127.0.0.1",
        port = 9022,
    },
    redis = {
		account = 
	    {
	            host = "127.0.0.1",
	            port = 6401,
	            auth = "123456",
	    },
	},
}

return config
