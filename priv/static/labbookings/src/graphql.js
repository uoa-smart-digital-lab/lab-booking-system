import { gql } from "@apollo/client";

// ----------------------------------------------------------------------------------------------------
// Common data for GraphQL
// ----------------------------------------------------------------------------------------------------
const GraphQL = 
{
    PERSONALL : gql`query { personAll { name upi } } `,
    ITEMALL : gql`query { itemAll { url name } } `,
    ITEMGET : gql`
        query itemGet($name: String!) 
        {
            itemGet (name: $name) {
                url
                name
                image
            }
        }`,

    BOOKINGALL : gql`
        query bookingAll($itemName: String!)
        {
            bookingAll (itemName: $itemName) { 
                bookings {
                    upi
                }
                item {
                    name
                }
            }
        }`,

    BOOKIN : gql`
        mutation bookIn($itemName: String!, $upi: String!)
        {
            bookIn (itemName: $itemName, upi: $upi)
            {
                bookings {
                    upi
                }
                item {
                    name
                }
            }
        }`,

    BOOKINOROUT : gql`
    mutation bookInOrOut($itemName: String!, $upi: String!)
    {
        bookInOrOut (itemName: $itemName, upi: $upi)
        {
            bookings {
                upi
            }
            item {
                name
            }
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
    }
}

export default GraphQL;
// ----------------------------------------------------------------------------------------------------
