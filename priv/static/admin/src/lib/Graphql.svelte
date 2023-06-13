<!------------------------------------------------------------------------------------------------------
  GraphQL definitions

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">

    //==================================================================================================
    // GraphQL fetch functions
    //==================================================================================================
    export class GraphQL {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        uri: string = '/graphql';   // default uri

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(uri: string = '/graphql') {
            this.uri = uri;
        }

        //----------------------------------------------------------------------------------------------
        // Private methods
        //----------------------------------------------------------------------------------------------
        private gql(session: Session = null, variables: {} = {}, gql:{name: string, gql: string} = null): Promise<any> {

            // Return a promise that is fulfilled when the fetch completes
            return new Promise((resolve, reject) => {
                // Send a fetch request to the server
                fetch(this.uri, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json', sessionid: session ? session.sessionid : "" },
                        body: JSON.stringify({ query: gql ? gql.gql : "", variables: variables }),
                    })
                    // If there was an OK response (ie status 200), then return the json data.  If not, return the status text
                    .then(response => {
                        if (response.ok) {  return response.json(); } 
                        else {              return response.statusText; }
                    })
                    // Even if the response was OK, this could be an error, so check for errors in the returned data
                    // and either return that by rejecting the promise, or the data by resolving the promise.
                    .then(data => {
                        if (data.errors && data.errors.length > 0) { reject(data.errors[0].message); }
                        else { resolve(data.data[gql.name]); }
                    })
                    // Anything else that might cause an error (eg a 404 error), reject the promise with the error.
                    .catch(error => { reject(error); })
                }
            );
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public query(session: Session = null, variables: {} = {}, query:{name: string, gql: string} = null): Promise<any> {
            return this.gql(session, variables, query);
        }

        public mutation(session: Session = null, variables: {} = {}, mutation:{name: string, gql: string} = null): Promise<any> {
            return this.gql(session, variables, mutation);
        }
    }
    //==================================================================================================



    //==================================================================================================
    // Enums
    //==================================================================================================
    export enum Usertype {"USER", "POWERUSER", "ADMIN"};
    export enum Itemtype {"FREE", "INDUCTION", "SUPERVISED"};
    //==================================================================================================



    //==================================================================================================
    // Type arrays
    //==================================================================================================
    export type Items = Array<Item>;
    export type Bookings = Array<Booking>;
    export type Persons = Array<Person>;
    //==================================================================================================



    //==================================================================================================
    // A session is returned when a user logs in
    //==================================================================================================
    export type SessionJSON = {sessionid: string, person: PersonJSON};
    export class Session {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        __typename : string = "Session";
        sessionid : string;
        person : Person;

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: SessionJSON = null) { this.set(data); }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            sessionid:  { type: "string",       editable: true,     input: "text",      width: 2 },
            person:     { type: "Person",       editable: true,     input: "object",    width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // GraphQL definitions
        //----------------------------------------------------------------------------------------------
        static _mutations = {
            login: {name: "login", gql: `
                mutation login ($upi:String!, $password:String!)
                {
                    login (upi:$upi, password:$password) {
                        sessionid person { upi name status }
                    }
                }`
            },
            logout: {name: "logout", gql: `
                mutation logout
                {
                    logout {
                        sessionid
                    }
                }`
            }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set(data: SessionJSON = null) {
            if (data) {
                this.sessionid = data["sessionid"] ? data["sessionid"] : "";
                this.person = new Person(data["person"]);
            } else {
                this.reset();
            }
        }
        public reset() {
            this.sessionid = "";
            this.person = new Person();
        }

        public login(graphql: GraphQL, upi: string, password: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(this, {upi: upi, password: password}, Session._mutations.login)
                .then((data) => {
                    this.set(data);
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        public logout(graphql: GraphQL): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(this, {}, Session._mutations.logout)
                .then((data) => {
                    this.reset();
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }
    };
    //==================================================================================================



    //==================================================================================================
    // An item can have some details, in this case a name
    //==================================================================================================
    export type ItemDetailsJSON = {name: string};
    export class ItemDetails {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        __typename : string = "ItemDetails";
        name: string;

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: ItemDetailsJSON = null) { this.set(data); }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            name:       { type: "string",       editable: true,     input: "text",      width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set (data: ItemDetailsJSON = null) {
            if (data) this.name = data["name"] ? data["name"] : "";
            else this.reset();
        }
        public reset() {
            this.name = "";
        }
    };
    //==================================================================================================
    


    //==================================================================================================
    // A Person can have some extra details, in this case a phone number and email address
    //==================================================================================================
    type PersonDetailsJSON = {phone: string, email: string};
    export class PersonDetails {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        __typename : string = "PersonDetails";
        phone: string;
        email: string;

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: PersonDetailsJSON = null) { this.set(data); }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            phone:      { type: "string",       editable: true,     input: "text",      width: 2 },
            email:      { type: "string",       editable: true,     input: "text",      width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set (data: PersonDetailsJSON = null) {
            if (data) {
                this.phone = data["phone"] ? data["phone"] : "";
                this.email = data["email"] ? data["email"] : "";
            } else {
                this.reset();
            }
        }
        public reset () {
            this.phone = "";
            this.email = "";
        }
    };
    //==================================================================================================



    //==================================================================================================
    // A Booking can have some extra details, in this case a details description
    //==================================================================================================
    export type BookingDetailsJSON = {details: string};
    export class BookingDetails {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        __typename : string = "BookingDetails";
        details: string;

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: BookingDetailsJSON = null) {
            this.set(data);
        }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            details:    { type: "string",       editable: true,     input: "text",      width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set (data: BookingDetailsJSON = null) {
            if (data) this.details = data["details"] ? data["details"] : "";
            else this.reset();
        }
        public reset () {
            this.details = "";
        }
    };
    //==================================================================================================



    //==================================================================================================
    // A bookable item
    //==================================================================================================
    export type ItemJSON = {name: string, image: string, url: string, details: ItemJSON, cost: number, bookable: boolean, access: number, bookings: BookingJSON[], inductions: PersonJSON[]};
    export class Item {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
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

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: ItemJSON = null) { this.set(data); }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            name:       { type: "string",       editable: true,     input: "text",      width: 2 },
            image:      { type: "string",       editable: true,     input: "image",     width: 2 },
            url:        { type: "string",       editable: true,     input: "url",       width: 2 },
            details:    { type: "ItemDetails",  editable: true,     input: "object",    width: 2 },
            cost:       { type: "number",       editable: true,     input: "number",    width: 1 },
            bookable:   { type: "boolean",      editable: true,     input: "checkbox",  width: 1 },
            access:     { type: "Itemtype",     editable: true,     input: "dropdown",  width: 2 },
            bookings:   { type: "Bookings",     editable: false,    input: "array",     width: 2 },
            inductions: { type: "Persons",      editable: false,    input: "array",     width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // GraphQL definitions
        //----------------------------------------------------------------------------------------------
        static _queries = {
            all: {name: "itemAll", gql: `
                query itemAll
                {
                    itemAll {
                        url name image details cost bookable access
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                }`
            },
            get: {name: "itemGet", gql: `
                query itemGet($name: String!) 
                {
                    itemGet (name: $name) {
                        url name image details cost bookable access
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                }`
            }
        };

        static _mutations = {
            add: {name: "itemAdd", gql: `
                mutation itemAdd ($name:String!, $image:String!, $url:String!, $details:Json!, $cost:Float!, $bookable:Boolean!, $access:Itemtype!)
                {
                    itemAdd (name:$name, image:$image, url:$url, details:$details, cost:$cost, bookable:$bookable, access:$access) {
                        name
                    }
                }`
            },
            update: {name: "itemUpdate", gql: `
                mutation itemUpdate ($name:String!, $image:String!, $url:String!, $details:Json!, $cost:Float!, $bookable:Boolean!, $access:Itemtype!)
                {
                    itemUpdate (name:$name, image:$image, url:$url, details:$details, cost:$cost, bookable:$bookable, access:$access) {
                        name
                    }
                }`
            },
            delete: {name: "itemDelete", gql: `
                mutation itemDelete ($name:String!)
                {
                    itemDelete (name:$name) {
                        name
                    }
                }`
            }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set(data: ItemJSON = null) {
            if (data) {
                this.name = data["name"];
                this.image = data["image"];
                this.url = data["url"];
                this.details = new ItemDetails(data["details"]);
                this.cost = data["cost"];
                this.bookable = data["bookable"];
                this.access = data["access"];
                this.bookings = []; data["bookings"] ? data["bookings"].forEach((booking: BookingJSON) => { this.bookings.push(new Booking(booking)); }) : [];
                this.inductions = []; data["inductions"] ? data["inductions"].forEach((induction: PersonJSON) => { this.inductions.push(new Person(induction)); }) : []
            } else {
                this.reset();
            }
        }
        public reset() {
            this.name = "";
            this.image = "";
            this.url = "";
            this.details = new ItemDetails();
            this.cost = 0;
            this.bookable = false;
            this.access = Itemtype.FREE;
            this.bookings = [];
            this.inductions = [];
        }

        public itemGet(graphql: GraphQL, session: Session, name: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.query(session, {name: name}, Item._queries.get)
                .then((data) => {
                    this.set(data);
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        //----------------------------------------------------------------------------------------------
        // Static class methods
        //----------------------------------------------------------------------------------------------
        static itemAll(graphql: GraphQL, session: Session = null): Promise<any> {
            return new Promise((resolve, reject) => {
                graphql.query(session, {name: name}, Item._queries.get)
                .then((data) => {
                    let result: Items = [];
                    console.log(data);
                    data.forEach((item: ItemJSON) => {
                        result.push(new Item(item));
                    });
                    resolve(result);
                })
                .catch((error) => {
                    reject(error);
                })
            });

            return graphql.query(session, {}, Item._queries.all);
        }

    };
    //==================================================================================================



    //==================================================================================================
    // A person
    //==================================================================================================
    type PersonJSON = {upi: string, name: string, password: string, status: number, details: PersonDetailsJSON, tokens: number, bookings: BookingJSON[], inductions: PersonJSON[]};
    export class Person {
        //----------------------------------------------------------------------------------------------
        // Definition
        //----------------------------------------------------------------------------------------------
        __typename : string = "Person";
        upi: string;
        name: string;
        password: string;
        status: Usertype;
        details: PersonDetails;
        tokens: number;
        bookings: Bookings | null;
        inductions: Persons | null;

        //----------------------------------------------------------------------------------------------
        // Constructor
        //----------------------------------------------------------------------------------------------
        constructor(data: PersonJSON = null) { this.set(data); }

        //----------------------------------------------------------------------------------------------
        // Table layout
        //----------------------------------------------------------------------------------------------
        static _format: {
            upi:        { type: "string",       editable: true,     input: "text",      width: 2 },
            name:       { type: "string",       editable: true,     input: "text",      width: 2 },
            password:   { type: "string",       editable: true,     input: "password",  width: 2 },
            status:     { type: "Usertype",     editable: true,     input: "dropdown",  width: 2 },
            details:    { type: "PersonDetails",editable: true,     input: "object",    width: 2 },
            tokens:     { type: "number",       editable: true,     input: "number",    width: 1 },
            bookings:   { type: "Bookings",     editable: false,    input: "array",     width: 2 },
            inductions: { type: "Persons",      editable: false,    input: "array",     width: 2 }
        }

        //----------------------------------------------------------------------------------------------
        // GraphQL definitions
        //----------------------------------------------------------------------------------------------
        static _queries = {
            all: {name: "personAll", gql: `
                query personAll
                {
                    personAll {
                        upi name password status details tokens
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                }`
            },
            get: {name: "personGet", gql: `
                query personGet($upi: String!) 
                {
                    personGet (upi: $upi) {
                        upi name password status details tokens
                        bookings { person { name upi } starttime endtime details }
                        inductions { upi }
                    }
                }`
            }
        };

        static _mutations = {
            add: {name: "personAdd", gql: `
                mutation personAdd ($upi:String!, $name:String!, $password:String!, $status:Usertype!, $details:Json!)
                {
                    personAdd (upi:$upi, name:$name, password:$password, status:$status, details:$details) {
                        upi
                    }
                }`
            },
            update: {name: "personUpdate", gql: `
                mutation personUpdate ($upi:String!, $name:String, $password:String, $status:Usertype, $details:Json)
                {
                    personUpdate (upi:$upi, name:$name, password:$password, status:$status, details:$details) {
                        upi
                    }
                }`
            },
            delete: {name: "personDelete", gql: `
                mutation personDelete ($upi:String!)
                {
                    personDelete (upi:$upi) {
                        upi
                    }
                }`
            },
            induct: {name: "personInduct", gql: `
                mutation personInduct ($upi:String!, $itemName:String!)
                {
                    personInduct (upi:$upi, itemName:$itemName) {
                        upi
                    }
                }`
            },
            unInduct: {name: "personUninduct", gql: `
                mutation personUninduct ($upi:String!, $itemName:String!)
                {
                    personUninduct (upi:$upi, itemName:$itemName) {
                        upi
                    }
                }`
            },
            adjustTokens: {name: "personAdjusttokens", gql: `
                mutation personAdjusttokens ($upi:String!, $tokens:Int!)
                {
                    personAdjusttokens (upi:$upi, tokens:$tokens) {
                        upi
                    }
                }`
            }
        }

        //----------------------------------------------------------------------------------------------
        // Public methods
        //----------------------------------------------------------------------------------------------
        public set(data: PersonJSON = null) {
            if (data) {
                this.upi = data["upi"] ? data["upi"] : "";
                this.name = data["name"] ? data["name"] : "";
                this.password = data["password"] ? data["password"] : "";
                this.status = data["status"] ? data["status"] : Usertype.USER;
                this.details = new PersonDetails(data["details"]);
                this.tokens = data["tokens"] ? data["tokens"] : 0;
                this.bookings = []; data["bookings"] ? data["bookings"].forEach((booking: BookingJSON) => { this.bookings.push(new Booking(booking)); }) : [];
                this.inductions = []; data["inductions"] ? data["inductions"].forEach((induction: PersonJSON) => { this.inductions.push(new Person(induction)); }) : []
            } else {
                this.reset();
            }
        }
        public reset() {
            this.upi = "";
            this.name = "";
            this.password = "";
            this.status = Usertype.USER;
            this.details = new PersonDetails();
            this.tokens = 0;
            this.bookings = [];
            this.inductions = [];
        }

        public personGet(graphql: GraphQL, session: Session, upi: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.query(session, {upi: upi}, Person._queries.get)
                .then((data) => {
                    this.set(data);
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        public personUpdate(graphql: GraphQL, session: Session, data: PersonJSON): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, data, Person._mutations.update)
                .then((data) => {
                    this.set(data);
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        //----------------------------------------------------------------------------------------------
        // Static class methods
        //----------------------------------------------------------------------------------------------
        static personAll(graphql: GraphQL, session: Session = null): Promise<any> {
            return new Promise((resolve, reject) => {
                graphql.query(session, {}, Person._queries.all)
                .then((data) => {
                    let result: Persons = [];
                    data.forEach((person: PersonJSON) => {
                        result.push(new Person(person));
                    });
                    resolve(result);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        static personAdd(graphql: GraphQL, session: Session, data: PersonJSON): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, {
                    upi: data["upi"] ? data["upi"] : "", 
                    name: data["name"] ? data["name"] : "", 
                    password: data["password"] ? data["password"] : "", 
                    status: data["status"] ? data["status"] : Usertype.USER, 
                    details: data["details"] ? data["details"] : {}
                }, Person._mutations.add)
                .then((data) => {
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        static personDelete(graphql: GraphQL, session: Session, upi: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, {upi: upi}, Person._mutations.delete)
                .then((data) => {
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        static personInduct(graphql: GraphQL, session: Session, upi: string, itemName: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, {upi: upi, itemName: itemName}, Person._mutations.induct)
                .then((data) => {
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        static personUninduct(graphql: GraphQL, session: Session, upi: string, itemName: string): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, {upi: upi, itemName: itemName}, Person._mutations.unInduct)
                .then((data) => {
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }

        static personAdjusttokens(graphql: GraphQL, session: Session, upi: string, tokens: number): Promise<void> {
            return new Promise((resolve, reject) => {
                graphql.mutation(session, {upi: upi, tokens: tokens}, Person._mutations.adjustTokens)
                .then((data) => {
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                })
            });
        }
    };
    //==================================================================================================



    //==================================================================================================
    // A booking
    //==================================================================================================
    export type BookingJSON = {person: PersonJSON, item: ItemJSON, starttime: Date, endtime: Date, details: BookingDetailsJSON};
    export class Booking {
        __typename : string = "Booking";
        person: Person;
        item: Item;
        starttime: Date;
        endtime: Date;
        details: BookingDetails

        constructor(data: BookingJSON = null) { this.set(data); }

        static _format = {
            person:      { type: "Person",       editable: true,     input: "object",    width: 2 },
            item:        { type: "Item",         editable: true,     input: "object",    width: 2 },
            starttime:   { type: "Date",         editable: true,     input: "datetime",  width: 2 },
            endtime:     { type: "Date",         editable: true,     input: "datetime",  width: 2 },
            details:     { type: "BookingDetails",editable: true,    input: "object",    width: 2 }
        }

        public set(data: BookingJSON = null) {
            if (data) {
                this.person = new Person(data["person"]);
                this.item = new Item(data["item"]);
                this.starttime = data["starttime"] ? new Date(data["starttime"]) : new Date();
                this.endtime = data["endtime"] ? new Date(data["endtime"]) : new Date();
                this.details = new BookingDetails(data["details"]);
            } else {
                this.reset();
            }
        }
        public reset() {
            this.person = new Person();
            this.item = new Item();
            this.starttime = new Date();
            this.endtime = new Date();
            this.details = new BookingDetails();
        }
    };
    //==================================================================================================



    //==================================================================================================
    // Helper functions
    //==================================================================================================
    export function getKeys(theType: string): string[] {
        switch (theType) {
            case "Person": return Object.keys(Person._format);
            case "Item": return Object.keys(Item._format);
            case "Booking": return Object.keys(Booking._format);
            case "PersonDetails": return Object.keys(PersonDetails._format);
            case "ItemDetails": return Object.keys(ItemDetails._format);
            case "Session": return Object.keys(Session._format);
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
    //==================================================================================================



    //--------------------------------------------------------------------------------------------------
    // The Querys and mutations
    //--------------------------------------------------------------------------------------------------
    // export const ITEMALL = gql`
    //     query itemAll
    //     {
    //         itemAll {
    //             url name image details cost bookable access
    //             bookings { person { name upi } starttime endtime details }
    //             inductions { upi }
    //         }
    //     } `;
    
    // export const ITEMGET = gql`
    //     query itemGet($name: String!) 
    //     {
    //         itemGet (name: $name) {
    //             url name image details cost bookable access
    //             bookings { person { name upi } starttime endtime details }
    //             inductions { upi }
    //         }
    //     } `;


    // export const LOGIN = gql`
    //     mutation login ($upi:String!, $password:String!)
    //     {
    //         login (upi:$upi, password:$password) {
    //             sessionid person { upi name status }
    //         }
    //     }`;

    // export const ITEMCHANGEBOOKING = gql`
    //     mutation itemChangebooking ($itemname:String!, $upi:String!, $starttime:DateTime!, $endtime:DateTime!, $newstarttime: DateTime, $newendtime: DateTime, $details:Json)
    //     {
    //         itemChangebooking(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime, newstarttime:$newstarttime, newendtime:$newendtime) {
    //             name
    //         }
    //     }`;

    // export const ITEMBOOK = gql`
    //     mutation itemBook ($itemname:String!, $upi:String!, $details:Json!, $starttime:DateTime!, $endtime:DateTime!)
    //     {
    //         itemBook(itemname:$itemname, upi:$upi, details:$details, starttime:$starttime, endtime:$endtime) {
    //             name
    //         }
    //     }`;

    // export const ITEMUNBOOK = gql`
    //     mutation itemUnbook ($itemname:String!, $starttime:DateTime!, $endtime:DateTime!)
    //     {
    //         itemUnbook(itemname:$itemname, starttime:$starttime, endtime:$endtime) {
    //             name
    //         }
    //     }`;

</script>
<!----------------------------------------------------------------------------------------------------->