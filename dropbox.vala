using Rest;

public class SimpleTweet {

    // From the app's dropbox page.
	private static const string APP_KEY = "0pn1vs879yuf4dx";
	private static const string APP_SECRET = "920tnyf2ft3og0q";
	
	private static const string URL = "https://api.dropbox.com/";
	private static const string CONTENT_URL = "https://api-content.dropbox.com";
	private static const string REQUEST_TOKEN_URL = "https://api.dropbox.com/1/oauth/request_token";

	private static const string FUNCTION_ACCESS_TOKEN = "1/oauth/access_token";

	private static const string PARAM_STATUS = "status";
	
	public static int main(string[] args) {
        var proxy = new OAuthProxy(APP_KEY, APP_SECRET, CONTENT_URL, false);
        ProxyCall call = proxy.new_call();
        call.set_function("1/files/dropbox/lol.txt");
        call.set_method("GET");
        call.add_param("GET", "lol");
        call.sync();
        
        return 0;
	}

	private void authorise() {

		/* Authenticating with Dropbox */
		var proxy = new OAuthProxy(APP_KEY, APP_SECRET, URL, false);

		// Request a token.
		try {
			proxy.request_token("1/oauth/request_token", "app_folder");
		} catch (Error e) {
			stderr.printf("Couldn't get request token: %s\n", e.message);
		}

		// The user has to go to the URL for our magic to work.
		stdout.printf("Please go to https://www.dropbox.com/1/oauth/authorize?oauth_token=%s \n", proxy.get_token());
		string pin = stdin.read_line();

		// access token
		try { proxy.access_token(FUNCTION_ACCESS_TOKEN, pin); }
		catch (Error e) {
			stderr.printf("Couldn't get access token: %s\n", e.message);
		}

	}
}
