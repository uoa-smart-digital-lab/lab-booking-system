<!------------------------------------------------------------------------------------------------------
  GraphQL definitions

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">
    import { gql } from '@apollo/client';

    //--------------------------------------------------------------------------------------------------
    // Enums and Types
    //--------------------------------------------------------------------------------------------------
    export enum Usertype {"USER", "POWERUSER", "ADMIN"};
    export enum Itemtype {"FREE", "INDUCTION", "SUPERVISED"};
        
    export class Session {
        sessionid : string;
        person : Person

        constructor(sessionid: string = "", person: Person = new Person()) {
            this.sessionid = sessionid;
            this.person = person;
        }

        static keys(): string[] {
            return ["sessionid", "person"];
        }
        static types(): string[] {
            return ["string", "Person"];
        }
    };

    export class ItemDetails {
        name: string

        constructor(name: string = "") {
            this.name = name;
        }

        static keys(): string[] {
            return ["name"];
        }
        static types(): string[] {
            return ["string"];
        }
    };
    export class PersonDetails {
        phone: string;
        email: string

        constructor(phone: string = "", email: string = "") {
            this.phone = phone;
            this.email = email;
        }

        static keys(): string[] {
            return ["phone", "email"];
        }
        static types(): string[] {
            return ["string", "string"];
        }
    };
    export type BookingDetails = {};
    export type Items = Item[];
    export type Bookings = Booking[];
    export type Persons = Person[];

    export class Item {
        name: string;
        image: string;
        url: string;
        details: ItemDetails;
        cost: number;
        bookable: boolean;
        access: Itemtype;
        bookings: Bookings | null;
        inductions: Persons | null

        constructor(name: string = "", image: string = "", url: string = "", details: ItemDetails = { name: "" }, cost: number = 0, bookable: boolean = false, access: Itemtype = Itemtype.FREE, bookings: Bookings | null = null, inductions: Persons | null = null) {
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

        static keys(): string[] {
            return ["name", "image", "url", "details", "cost", "bookable", "access", "bookings", "inductions"];
        }
        static types(): string[] {
            return ["string", "string", "string", "ItemDetails", "number", "boolean", "Itemtype", "Bookings", "Persons"];
        }
        static widths(): string[] {
            return ["1", "1", "1", "1", "1", "1", "1", "1", "1"];
        }
    };

    export class Person {
        upi: string;
        name: string;
        password: string;
        status: Usertype;
        details: PersonDetails;
        tokens: number;
        bookings: Bookings | null;
        inductions: Persons | null

        constructor(upi: string = "", name: string = "", password: string = "", status: Usertype = Usertype.USER, details: PersonDetails = { phone: "", email: "" }, tokens: number = 0, bookings: Bookings | null = null, inductions: Persons | null = null) {
            this.upi = upi;
            this.name = name;
            this.password = password;
            this.status = status;
            this.details = details;
            this.tokens = tokens;
            this.bookings = bookings;
            this.inductions = inductions;
        }

        static keys(): string[] {
            return ["upi", "name", "password", "status", "details", "tokens", "bookings", "inductions"];
        }
        static types(): string[] {
            return ["string", "string", "string", "Usertype", "PersonDetails", "number", "Bookings", "Persons"];
        }
    };

    export class Booking {
        person: Person;
        item: Item;
        starttime: Date;
        endtime: Date;
        details: BookingDetails

        constructor(person: Person = new Person(), item: Item = new Item(), starttime: Date = new Date(), endtime: Date = new Date(), details: BookingDetails = {}) {
            this.person = person;
            this.item = item;
            this.starttime = starttime;
            this.endtime = endtime;
            this.details = details;
        }

        static keys(): string[] {
            return ["person", "item", "starttime", "endtime", "details"];
        }
        static types(): string[] {
            return ["Person", "Item", "Date", "Date", "BookingDetails"];
        }
    };


    export function getKeys(theType: string): string[] {
        switch (theType) {
            case "Person": return Person.keys();
            case "Item": return Item.keys();
            case "Booking": return Booking.keys();
            case "PersonDetails": return PersonDetails.keys();
            case "ItemDetails": return ItemDetails.keys();
            case "Session": return Session.keys();
            default: return [];
        }
    }
    export function getTypes(theType: string): string[] {
        switch (theType) {
            case "Person": return Person.types();
            case "Item": return Item.types();
            case "Booking": return Booking.types();
            case "PersonDetails": return PersonDetails.types();
            case "ItemDetails": return ItemDetails.types();
            case "Session": return Session.types();
            default: return [];
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