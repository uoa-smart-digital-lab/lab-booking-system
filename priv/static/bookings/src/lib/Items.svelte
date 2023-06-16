<!------------------------------------------------------------------------------------------------------
  Display list of items

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Cards, Items } from "svelte-fomantic-ui";
    import type { Item as ItemT, ItemDetails, Person, Booking } from './Graphql.svelte';
    import type { } from './Types.svelte';

    import Item from "./Item.svelte";

    export let items: ItemT[];

    export let searchString : string;               // A string to match against to show only the items being searched for.
    export let loggedIn : boolean;                  // Whether a user is logged in or not
    export let upi : string;                        // Currently logged in user's UPI
    export let inducted : boolean;                  // Whether to show only items the user is inducted for, or all items.
    export let availability : boolean;              // Whether to show only items that are currently available for booking.
    export let qrcode: boolean;
    export let list: boolean;
    export let numCols: number;

    // Create a date time at zero time zone from the current time and date
    const rightNow = () => {
        let now = new Date();
        let nowString = (now.getFullYear().toString() + "-" + ((now.getMonth()<9)?"0":"") + (now.getMonth()+1).toString() + "-" + ((now.getDate()<10)?"0":"") + now.getDate().toString() + "T" + ((now.getHours()<10)?"0":"") + now.getHours().toString() + ":" + ((now.getMinutes()<10)?"0":"") + now.getMinutes().toString() + ":00+00:00");
        return (new Date(nowString));
    }

    // Get the current time and refetch the items
    let now = rightNow();
    console.log(now);

    // Get the name from the details if it exists, otherwise return an empty string rather than undefined
    function getname (details : ItemDetails) : string { return(details.name ? details.name : ""); }

    // Check whether the search string is in the name of the item or the details.name of the item. Or if the search string is empty, return true.
    const checkSearch = (item : ItemT, searchString : string) : boolean => 
        (item.bookable && item && (item.name.toLowerCase().includes(searchString.toLowerCase()) || getname(item.details).toLowerCase().includes(searchString.toLowerCase()) || (searchString === "")));

    // Check whether the person can book the item.  Either it is free to use (so return true) or the user must be inducted, in which case they must be named in the inducted list to return true
    const checkInducted = (item : ItemT, inducted : boolean, upi : string) : boolean => 
        ((item.access.toString() === "FREE") ? true : ((item.access.toString() === "INDUCTION") ? (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), !inducted)) : !inducted));

    // Check whether the given time is between the start and end times.
    const timeOverlaps = (startTime : Date, endTime : Date, testTime : Date) : boolean => (testTime >= startTime && testTime <= endTime);


    // Check whether the current item is presently available (ie not currently booked by someone else.)
    const checkAvailability = (item : ItemT, today : Date) : boolean => {     
        return (!(item.bookings.reduce((acc : boolean, curr : Booking) => acc || timeOverlaps(new Date(curr.starttime), new Date(curr.endtime), today), false)));
    }

</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Cards ui _={list?"one horizontal":(numCols===1?"one":numCols===2?"two":numCols===3?"three":"four")} style={"margin: 0.75em 0.25em !important;"}>
    {#each items as item}
        {#if availability}
            {#if checkAvailability(item, now)}
                {#if (checkSearch(item, searchString) && checkInducted(item, inducted, upi))}                
                    <Item {list} {qrcode} {item} on:book on:showDetails {loggedIn} {upi} available={true} {numCols}/>
                {/if}
            {/if}
        {:else}
            {#if (checkSearch(item, searchString) && checkInducted(item, inducted, upi))}                
                <Item {list} {qrcode} {item} on:book on:showDetails {loggedIn} {upi} available={checkAvailability(item, now)} {numCols}/>
            {/if}
        {/if}
    {/each}
</Cards>
<!----------------------------------------------------------------------------------------------------->
