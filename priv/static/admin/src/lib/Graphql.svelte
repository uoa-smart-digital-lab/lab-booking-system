<!------------------------------------------------------------------------------------------------------
  GraphQL definitions

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">
    import { gql, ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient, mutation } from 'svelte-apollo';
    import Items from 'svelte-fomantic-ui/src/lib/views/Items.svelte';

    export class GraphQL {
        static start() {
            // GraphQL client setup 
            const client = new ApolloClient({
                uri:  '/api',
                cache: new InMemoryCache()
            });
            setClient(client);
       }
    }


    //--------------------------------------------------------------------------------------------------
    // Enums and Types
    //--------------------------------------------------------------------------------------------------
    export enum Usertype {"USER", "POWERUSER", "ADMIN"};
    export enum Itemtype {"FREE", "INDUCTION", "SUPERVISED"};
        
    //--------------------------------------------------------------------------------------------------
    // A session is returned when a user logs in
    //--------------------------------------------------------------------------------------------------
    export class Session {
        __typename : string = "Session";
        sessionid : string;
        person : Person;

        constructor(sessionid: string = "", person: Person = new Person()) {
            this.sessionid = sessionid;
            this.person = person;
        }

        set(session:{}) {
            this.sessionid = session["sessionid"];
            this.person = session["person"];
        }
        reset() {
            this.sessionid = "";
            this.person = new Person();
        }

        static _format: {
            sessionid: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            },
            person: {
                type: "Person",
                editable: true,
                input: "object",
                width: 2
            }
        }

        static _keys = ["sessionid", "person"];

        private doLogin = mutation(gql`
                mutation login ($upi:String!, $password:String!)
                {
                    login (upi:$upi, password:$password) {
                        sessionid person { upi name status }
                    }
                }`);

        private doLogout = mutation(gql`
                mutation logout ($sessionid:String!)
                {
                    logout (sessionid:$sessionid) {
                        sessionid
                    }
                }`);

        public login(upi: string, password: string): Promise<void> {
            return new Promise<void>((resolve, reject) => {
                this.doLogin({ variables: { upi: upi, password: password } })
                .then((result: any) => { this.set(result.data.login); resolve(); })
                .catch((error: { graphQLErrors: [{ message: string }] }) => { reject(error.graphQLErrors[0].message); });
            });
        }

        public logout(): Promise<void> {
            return new Promise<void>((resolve, reject) => {
                this.doLogout({ variables: { sessionid: this.sessionid } })
                .then((result: any) => { this.reset(); resolve(); })
                .catch((error: { graphQLErrors: [{ message: string }] }) => { reject(error.graphQLErrors[0].message); });
            });
        }
    };
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // An item can have some details, in this case a name
    //--------------------------------------------------------------------------------------------------
    export class ItemDetails {
        __typename : string = "ItemDetails";
        name: string;

        constructor(name: string = "") {
            this.name = name;
        }

        static _format: {
            name: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            }
        }

        static _keys = ["name"];
    };
    //--------------------------------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------------------------------
    // A Person can have some extra details, in this case a phone number and email address
    //--------------------------------------------------------------------------------------------------
    export class PersonDetails {
        __typename : string = "PersonDetails";
        phone: string;
        email: string;

        constructor(phone: string = "", email: string = "") {
            this.phone = phone;
            this.email = email;
        }

        static _format: {
            phone: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            },
            email: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            }
        }

        static _keys = ["phone", "email"];
    };
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // A Booking can have some extra details, in this case a details description
    //--------------------------------------------------------------------------------------------------
    export class BookingDetails {
        __typename : string = "BookingDetails";
        details: string;

        constructor(details: string = "") {
            this.details = details;
        }

        static _format: {
            details: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            }
        }

        static _keys = ["details"];
    };
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // Some type arrays
    //--------------------------------------------------------------------------------------------------
    export type Items = Array<Item>;
    export type Bookings = Array<Booking>;
    export type Persons = Array<Person>;
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // A bookable item
    //--------------------------------------------------------------------------------------------------
    export class Item {
        __typename : string = "Item";
        name: string;
        image: string;
        url: string;
        details: ItemDetails;
        cost: number;
        bookable: boolean;
        access: Itemtype;
        bookings: Bookings | null;
        inductions: Persons | null;

        constructor(name: string = "", image: string = "", url: string = "", details: ItemDetails = new ItemDetails(), cost: number = 0, bookable: boolean = false, access: Itemtype = Itemtype.FREE, bookings: Bookings = null, inductions: Persons = null) {
            this.name = name;
            this.image = image;
            this.url = url;
            this.details = details;
            this.cost = cost;
            this.bookable = bookable;
            this.access = access;
            this.bookings = bookings;
            this.inductions = inductions;
        }

        static _format: {
            name: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            },
            image: {
                type: "string",
                editable: true,
                input: "image",
                width: 2
            },
            url: {
                type: "string",
                editable: true,
                input: "url",
                width: 2
            },
            details: {
                type: "ItemDetails",
                editable: true,
                input: "object",
                width: 2
            },
            cost: {
                type: "number",
                editable: true,
                input: "number",
                width: 1
            },
            bookable: {
                type: "boolean",
                editable: true,
                input: "checkbox",
                width: 1
            },
            access: {
                type: "Itemtype",
                editable: true,
                input: "dropdown",
                width: 2
            },
            bookings: {
                type: "Bookings",
                editable: false,
                input: "array",
                width: 2
            },
            inductions: {
                type: "Persons",
                editable: false,
                input: "array",
                width: 2
            }
        }

        static _keys = ["name", "image", "url", "details", "cost", "bookable", "access", "bookings", "inductions"];

        private doItemAll = mutation(gql`
                query itemAll
                {
                    itemAll {
                        url name image details cost bookable access
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                }`);

        public ItemAll(): Promise<Items> {
            return new Promise<Items>((resolve, reject) => {
                this.doItemAll({ variables: { } })
                .then((result: any) => { 
                    let items:Items = result.data.itemAll;
                    resolve(items); 
                })
                .catch((error: { graphQLErrors: [{ message: string }] }) => { reject(error.graphQLErrors[0].message); });
            });
        }

        static _queries = {
            all: gql`
                query itemAll
                {
                    itemAll {
                        url name image details cost bookable access
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                } `,
            get: gql`
                query itemGet($name: String!) 
                {
                    itemGet (name: $name) {
                        url name image details cost bookable access
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                } `
        };

        static _mutations = {
            add: gql`
                mutation itemAdd ($name:String!, $image:String!, $url:String!, $details:Json!, $cost:Float!, $bookable:Boolean!, $access:Itemtype!)
                {
                    itemAdd (name:$name, image:$image, url:$url, details:$details, cost:$cost, bookable:$bookable, access:$access) {
                        name
                    }
                }`,
            update: gql`
                mutation itemUpdate ($name:String!, $image:String!, $url:String!, $details:Json!, $cost:Float!, $bookable:Boolean!, $access:Itemtype!)
                {
                    itemUpdate (name:$name, image:$image, url:$url, details:$details, cost:$cost, bookable:$bookable, access:$access) {
                        name
                    }
                }`,
            delete: gql`
                mutation itemDelete ($name:String!)
                {
                    itemDelete (name:$name) {
                        name
                    }
                }`
        }
    };
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // A person
    //--------------------------------------------------------------------------------------------------
    export class Person {
        __typename : string = "Person";
        upi: string;
        name: string;
        password: string;
        status: Usertype;
        details: PersonDetails;
        tokens: number;
        bookings: Bookings | null;
        inductions: Persons | null;

        constructor(upi: string = "", name: string = "", password: string = "", status: Usertype = Usertype.USER, details: PersonDetails = new PersonDetails(), tokens: number = 0, bookings: Bookings = null, inductions: Persons = null) {
            this.upi = upi;
            this.name = name;
            this.password = password;
            this.status = status;
            this.details = details;
            this.tokens = tokens;
            this.bookings = bookings;
            this.inductions = inductions;
        }

        static _format: {
            upi: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            },
            name: {
                type: "string",
                editable: true,
                input: "text",
                width: 2
            },
            password: {
                type: "string",
                editable: true,
                input: "password",
                width: 2
            },
            status: {
                type: "Usertype",
                editable: true,
                input: "dropdown",
                width: 2
            },
            details: {
                type: "PersonDetails",
                editable: true,
                input: "object",
                width: 2
            },
            tokens: {
                type: "number",
                editable: false,
                input: "number",
                width: 1
            },
            bookings: {
                type: "Bookings",
                editable: false,
                input: "array",
                width: 2
            },
            inductions: {
                type: "Persons",
                editable: false,
                input: "array",
                width: 2
            }
        }

        static _keys = ["upi", "name", "password", "status", "details", "tokens", "bookings", "inductions"];

        static _queries = {
            all: gql`
                query personAll
                {
                    personAll {
                        upi name password status details tokens
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                } `,
            get: gql`
                query personGet($upi: String!) 
                {
                    personGet (upi: $upi) {
                        upi name password status details tokens
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                } `
        };

        static _mutations = {
            add: gql`
                mutation personAdd ($upi:String!, $name:String!, $password:String!, $status:Usertype!, $details:Json!)
                {
                    personAdd (upi:$upi, name:$name, password:$password, status:$status, details:$details) {
                        upi
                    }
                }`,
            update: gql`
                mutation personUpdate ($upi:String!, $name:String!, $password:String!, $status:Usertype!, $details:Json!)
                {
                    personUpdate (upi:$upi, name:$name, password:$password, status:$status, details:$details) {
                        upi
                    }
                }`,
            delete: gql`
                mutation personDelete ($upi:String!)
                {
                    personDelete (upi:$upi) {
                        upi
                    }
                }`
        }
    };
    //--------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------
    // A booking
    //--------------------------------------------------------------------------------------------------
    export class Booking {
        __typename : string = "Booking";
        person: Person;
        item: Item;
        starttime: Date;
        endtime: Date;
        details: BookingDetails

        constructor(person: Person = new Person(), item: Item = new Item(), starttime: Date = new Date(), endtime: Date = new Date(), details: BookingDetails = new BookingDetails()) {
            this.person = person;
            this.item = item;
            this.starttime = starttime;
            this.endtime = endtime;
            this.details = details;
        }

        static _format = {
            person: {
                type: "Person",
                editable: true,
                input: "object",
                width: 2
            },
            item: {
                type: "Item",
                editable: true,
                input: "object",
                width: 2
            },
            starttime: {
                type: "Date",
                editable: true,
                input: "datetime",
                width: 2
            },
            endtime: {
                type: "Date",
                editable: true,
                input: "datetime",
                width: 2
            },
            details: {
                type: "BookingDetails",
                editable: true,
                input: "object",
                width: 2
            }
        }

        static _keys = ["person", "item", "starttime", "endtime", "details"];
    };
    //--------------------------------------------------------------------------------------------------

    export type BookingTypes = Person | Item | Booking | PersonDetails | ItemDetails | Session | Usertype | String | Number | Boolean | Usertype;


    export function getKeys(theType: string): string[] {
        switch (theType) {
            case "Person": return Person._keys;
            case "Item": return Item._keys;
            case "Booking": return Booking._keys;
            case "PersonDetails": return PersonDetails._keys;
            case "ItemDetails": return ItemDetails._keys;
            case "Session": return Session._keys;
            default: return [];
        }
    }

    export function getFormat(theType: string): object {
        switch (theType) {
            case "Person": return Person._format;
            case "Item": return Item._format;
            case "Booking": return Booking._format;
            case "PersonDetails": return PersonDetails._format;
            case "ItemDetails": return ItemDetails._format;
            case "Session": return Session._format;
            default: return {};
        }
    }

    //--------------------------------------------------------------------------------------------------
    // The Querys and mutations
    //--------------------------------------------------------------------------------------------------
    export const ITEMALL = gql`
        query itemAll
        {
            itemAll {
                url name image details cost bookable access
                bookings { person { name upi } starttime endtime details }
                inductions { upi }
            }
        } `;
    
    export const ITEMGET = gql`
        query itemGet($name: String!) 
        {
            itemGet (name: $name) {
                url name image details cost bookable access
                bookings { person { name upi } starttime endtime details }
                inductions { upi }
            }
        } `;


    export const LOGIN = gql`
        mutation login ($upi:String!, $password:String!)
        {
            login (upi:$upi, password:$password) {
                sessionid person { upi name status }
            }
        }`;

    export const ITEMCHANGEBOOKING = gql`
        mutation itemChangebooking ($itemname:String!, $upi:String!, $starttime:DateTime!, $endtime:DateTime!, $newstarttime: DateTime, $newendtime: DateTime, $details:Json)
        {
            itemChangebooking(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime, newstarttime:$newstarttime, newendtime:$newendtime) {
                name
            }
        }`;

    export const ITEMBOOK = gql`
        mutation itemBook ($itemname:String!, $upi:String!, $details:Json!, $starttime:DateTime!, $endtime:DateTime!)
        {
            itemBook(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime) {
                name
            }
        }`;

    export const ITEMUNBOOK = gql`
        mutation itemUnbook ($itemname:String!, $starttime:DateTime!, $endtime:DateTime!)
        {
            itemUnbook(itemname:$itemname, starttime:$starttime, endtime:$endtime) {
                name
            }
        }`;

</script>
<!----------------------------------------------------------------------------------------------------->