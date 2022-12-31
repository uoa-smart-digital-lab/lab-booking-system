<!------------------------------------------------------------------------------------------------------
  GraphQL definitions
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">
    import { gql } from '@apollo/client';

    export enum Status {"USER", "POWERUSER", "ADMIN"};
    export enum Access {"FREE", "INDUCTION", "SUPERVISED"};
        
    export type Session = {
        sessionid : string, 
        person : Person
    };

    export type ItemDetails = {
        name: string
    };
    export type PersonDetails = {};
    export type BookingDetails = {};
    export type Inductions = [ Person ];

    export type Item = {
        name: string,
        image: string,
        url: string,
        details: ItemDetails,
        cost: number,
        bookable: boolean,
        access: Access,
        bookings: [ Booking ],
        inductions: [ Person ]
    };

    export type Person = {
        upi: string,
        name: string,
        status: Status,
        details: PersonDetails,
        tokens: number,
        inductions: [ Item ],
        bookings: [ Booking ]
    };

    export type Booking = {
        person: Person,
        item: Item,
        starttime: Date,
        endtime: Date,
        details: BookingDetails
    };

    export const ITEMALL = gql`
        query { itemAll {
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
        }`;

    export const ITEMCHANGEBOOKING = gql`
        mutation itemChangebooking ($itemname:String!, $upi:String!, $starttime:DateTime!, $endtime:DateTime!, $newstarttime: DateTime, $newendtime: DateTime, $details:Json)
        {
            itemChangebooking(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime, newstarttime:$newstarttime, newendtime:$newendtime) {
                name
                url
                image
                bookings {
                    person {
                        name
                        upi
                    }
                    item {
                        name
                    }
                    starttime
                    endtime
                    details
                }
            }
        }`;

    export const ITEMBOOK = gql`
        mutation itemBook ($itemname:String!, $upi:String!, $details:Json!, $starttime:DateTime!, $endtime:DateTime!)
        {
            itemBook(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime) {
                name
                url
                image
                bookings {
                    person {
                        name
                        upi
                    }
                    item {
                        name
                    }
                    starttime
                    endtime
                    details
                }
            }
        }`;

</script>