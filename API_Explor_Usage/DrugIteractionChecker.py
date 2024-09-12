import requests
import json
def get_rxnorm_id(drug_name):
    """Fetch the RxNorm ID for a given drug name."""
    url = f"https://www.medscape.com/api/quickreflookup/LookupService.ashx?q={drug_name}&sz=500&type=10417&metadata=has-interactions&format=json&jsonp=MDICshowResults"
    response = requests.get(url)
    if(response.status_code != 200):
        print(f"Error retriving ID for {drug_name}")
        return ""

    response_string = response.text
    
    cleaned_response = response_string.replace("MDICshowResults(", "").replace(");", "")

    # Parse the JSON string
    response_data = json.loads(cleaned_response)
    # Extract the ids from the "references" arrays
    ids = []
    if len(response_data['types']) > 0:
        ids = [reference['id'] for reference in response_data['types'][0]['references']]
    # Print the extracted IDs
    if len(ids) != 0:
        return ids[0]
    else:
        print(f"Error retriving ID for {drug_name}")
        return ""

    
    # Function to parse interactions by severity

def parse_interactions(response):
    """Gets a list of interactions between a list of medications."""
    if response['errorCode'] != 0 and response['multiInteractions']:
        # Sort by severity level (severityId)
        sorted_interactions = sorted(response['multiInteractions'], key=lambda x: x['severityId'], reverse=True)
        
        # Group by severity
        severity_dict = {}
        for interaction in sorted_interactions:
            severity = interaction['severity']
            if severity not in severity_dict:
                severity_dict[severity] = []
            severity_dict[severity].append(interaction)

        # Print interactions by severity
        for severity, interactions in severity_dict.items():
            print(f"Severity Level: {severity}")
            for interaction in interactions:
                print(f"Description: {interaction['text']}")
    else:
        print("No interactions found.")

def get_itercation_data(medication_ids):
    """Gets a list of interactions between a list of medications."""
    querycheck = ','.join(medication_ids)
    url = f"https://reference.medscape.com/druginteraction.do?action=getMultiInteraction&ids={querycheck}"
    response = requests.get(url)
    # print(response.json())
    parse_interactions(response.json())

def check_interactions(medications):
    """Check for interactions between a list of medications."""
    ids = []
    interactions = {}

    # Get RxNorm IDs for all medications
    for drug in medications:
        rxnorm_id = get_rxnorm_id(drug)
        if rxnorm_id != "":  
            ids.append(rxnorm_id)
    if len(ids) > 1:
        get_itercation_data(ids)

# Example usage
medications = ["ibuprofen", "aspirin"]  # Add your list of medications here
check_interactions(medications)
