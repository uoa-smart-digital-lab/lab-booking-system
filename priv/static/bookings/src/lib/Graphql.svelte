<!------------------------------------------------------------------------------------------------------
GraphQL definitions
------------------------------------------------------------------------------------------------------->
<script context="module">
    import { gql } from '@apollo/client';

    export const ITEMALL = gql`
        query { itemAll 
        {
            url
            image
            name
            access
            bookable
            details
            inductions {
                upi
            }
            bookings { 
                person { name upi }
                starttime
                endtime
            }           
        }
    } `;

    
    export const ITEMGET = gql`
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
        }`;


    export const LOGIN = gql`
        mutation login ($upi:String!, $password:String!)
        {
            login(upi:$upi, password:$password) {
                sessionid
                person { upi name }
            }
        }
    `
</script>