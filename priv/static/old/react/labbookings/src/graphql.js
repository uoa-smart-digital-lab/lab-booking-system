import { gql, ApolloClient, InMemoryCache } from "@apollo/client";

// ----------------------------------------------------------------------------------------------------
// Common data for GraphQL
// ----------------------------------------------------------------------------------------------------
const GraphQL = 
{
    PERSONALL : gql`query { personAll { name upi } } `,
    ITEMALL : gql`query { itemAll { url image name access bookable details } } `,
    ITEMGET : gql`
        query itemGet($name: String!) 
        {
            itemGet (name: $name) {
                url
                name
                image
                details
                cost
                bookable
                access
                bookings { 
                    person { name upi }
                    starttime
                    endtime
                }
                inductions {
                    upi
                }
            }
        }`,

    BOOKINGALL : gql`
        query itemGet($name: String!)
        {
            itemGet (name: $name) { 
                name
                url
                image
                details
                cost
                bookable
                access
                bookings {
                    person { name upi }
                    starttime
                    endtime
                }
                inductions {
                    upi
                }
            }
        }`,

    ITEMBOOK : gql`
        mutation itemBook ($itemname:String!, $upi:String!, $details:Json!, $starttime:DateTime!, $endtime:DateTime!)
        {
            itemBook(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime) {
                name
            }
        }`,

    errorcodes :
    {
        "noparam" :                 "No parameters supplied",
        "noitem"  :                 "Item does not exist",
        "itemexists" :              "Item already exists",
        "problemdeletingitem" :     "Problem deleting Item",

        "noperson" :                "This UPI is not registered",
        "personexists" :            "This UPI already exist in this system",
        "problemdeletingperson" :   "Problem deleting Person",

        "notadmin" :                "Must be admin to do this",
        "nosession" :               "Incorrect or absent SessionID",
        "badpassword" :             "Incorrect password",
        "problemdeletingsession" :  "Problem deleting Session"
    },

    client : new ApolloClient({
        uri: '/api',
        cache: new InMemoryCache()
      }),
    
    fetch : ({uri, headers, body}) => {
    return new Promise ((resolve, reject) => {
        fetch(uri, { method:"POST", headers:headers, body:body })
        .then (result => result.json())
        .then ((result) => {
            resolve(result)
        })
        .catch ((err) => {
            reject(err);
        });
    });
    }
}

export default GraphQL;
// ----------------------------------------------------------------------------------------------------
