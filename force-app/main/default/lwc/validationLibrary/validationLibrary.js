/* eslint-disable no-console */
function checkByPattern (value, pattern) {
    const re = new RegExp( pattern );
    const valid = re.test( value );
    return valid;
}  

const checkTargetState = (target, staticData) => {
    const pattern = staticData[target.keyName].validationRegex;
    if ( pattern ) {
        if ( checkByPattern(target.myValue, pattern) ) { 
            target.setSuccess(); 
        } else { 
            target.errorMessage = staticData[target.keyName].errorMessage; 
        }
    }
}

const checkStepState = (stepState, staticData) => {
    return  Object.keys(stepState).
                reduce( (result = true, nextKey) => {
                    const pattern = staticData[nextKey].validationRegex;
                    const valid = checkByPattern(stepState[nextKey], pattern);
                    return result && valid;
                });
}

export {
    checkTargetState,
    checkStepState
};