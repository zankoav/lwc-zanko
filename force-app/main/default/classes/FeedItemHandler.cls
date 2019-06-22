/**
 * Created by Andrei.Moiseev on 28.11.2017.
 */
public class FeedItemHandler {
	// Regex string for parser input stirng
	private static final String regex = '^Date=\'([0-9]{1,2}).([0-9]{1,2}).([0-9]{4})\'\\s*(.+)$';

	/*******************************************************************************
	*  Name            : parserFeedItemBody()
	*  Summary         : parser body field from FeedItem and separates the date and message
	*  CreatedDate     : 28/11/2017
	*  Parameters      : newFeedItemList - new List FeedItem
	*  Returns         : void
	******************************************************************************/
	public static void parserFeedItemBody(List<FeedItem> newFeedItemList) {
		Pattern regexPattern = Pattern.compile(regex);

		for(FeedItem item : newFeedItemList) {
			String body = item.Body;
			Matcher regexMatcher = regexPattern.matcher(body);

			if(regexMatcher.find()) {
				item.Body = regexMatcher.group(4);
			}
		}
	}

}