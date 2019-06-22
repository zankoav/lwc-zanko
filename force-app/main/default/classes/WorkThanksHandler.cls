/**
 * Created by Andrei.Moiseev on 28.11.2017.
 */
public class WorkThanksHandler {
	// Regex string for parser input stirng
	private static final String regex = '^Date=\'([0-9]{1,2}).([0-9]{1,2}).([0-9]{4})\'\\s*(.+)$';

	/*******************************************************************************
	*  Name            : parserWorkThanksMessage()
	*  Summary         : parser message field from WorkThanks and separates the date and message
	*  CreatedDate     : 28/11/2017
	*  Parameters      : newWorkThanksList - new List WorkThanks
	*  Returns         : void
	******************************************************************************/
	public static void parserWorkThanksMessage(List<WorkThanks> newWorkThanksList) {
		Pattern regexPattern = Pattern.compile(regex);

		for(WorkThanks item : newWorkThanksList) {
			String message = item.Message;
			Matcher regexMatcher = regexPattern.matcher(message);
			regexMatcher.find();

			item.DateOfAppointment__c = parserOfDate(regexMatcher);
			item.Message = regexMatcher.group(4);
		}
	}

	private static Date parserOfDate(Matcher regexMatcher) {
		String month = regexMatcher.group(1);
		String day = regexMatcher.group(2);
		String year = regexMatcher.group(3);
		String newDate = year + '-' + month + '-' + day;
		return Date.valueOf(newDate);
	}
}