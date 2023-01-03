<!------------------------------------------------------------------------------------------------------
  All the items in the system
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { query } from 'svelte-apollo';
    import ItemObj from './Item.svelte';
	import { SimpleGrid } from '@svelteuidev/core';
    import { ITEMALL } from './Graphql.svelte';
    import type { Item, ItemDetails, Person, Booking } from './Graphql.svelte';
    import { beforeUpdate } from 'svelte';
    
    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let search : string;                     // A string to match against to show only the items being searched for.
    export let loggedIn : boolean;                  // Whether a user is logged in or not
    export let upi : string;                        // Currently logged in user's UPI
    export let inducted : boolean;                  // Whether to show only items the user is inducted for, or all items.
    export let availability : boolean;              // Whether to show only items that are currently available for booking.
    export let bookItem : (item : Item) => void;    // A function to call when a specific item is to be booked.
    export let showItem : (url : string) => void;   // The funcion to call when the item details button is pressed

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let now : Date;

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // The GraphQL query structure for login
    const items : any = query(ITEMALL, { variables: {} });

    // Force reload of the data
    const reload = () => { items.refetch(); }

    // Get the name from the details if it exists, otherwise return an empty string rather than undefined
    const getname = (details : ItemDetails) : string => (details.name ? details.name : "");

    // Check whether the search string is in the name of the item or the details.name of the item. Or if the search string is empty, return true.
    const checkSearch = (item : Item, search : string) : boolean => 
        (item.bookable && (item.name.includes(search.toLowerCase()) || getname(item.details).includes(search.toLowerCase()) || (search === "")));

    // Check whether the person can book the item.  Either it is free to use (so return true) or the user must be inducted, in which case they must be named in the inducted list to return true
    const checkInducted = (item : Item, inducted : boolean, upi : string) : boolean => 
        ((item.access.toString() === "FREE") ? true : ((item.access.toString() === "INDUCTION") ? (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), !inducted)) : !inducted));

    const timeOverlaps = (startTime : Date, endTime : Date, testTime : Date) : boolean => {
        // console.log({start:startTime, end:endTime, current:testTime, result: (testTime >= startTime && testTime <= endTime)});
        return (testTime >= startTime && testTime <= endTime);
    }

    // Create a date time at zero time zone from the current time and date
    const rightNow = () => {
        let now = new Date();
        let nowString = (now.getFullYear().toString() + "-" + ((now.getMonth()<9)?"0":"") + (now.getMonth()+1).toString() + "-" + ((now.getDate()<10)?"0":"") + now.getDate().toString() + "T" + ((now.getHours()<10)?"0":"") + now.getHours().toString() + ":" + ((now.getMinutes()<10)?"0":"") + now.getMinutes().toString() + ":00+00:00");
        return (new Date(nowString));
    }

    // Check whether the current item is presently available (ie not currently booked by someone else.)
    const checkAvailability = (item : Item, today : Date) : boolean => {     
        return (!(item.bookings.reduce((acc : boolean, curr : Booking) => acc || timeOverlaps(new Date(curr.starttime), new Date(curr.endtime), today), false)));
    }

    // Get the current time and refetch the items
    beforeUpdate(() => {
        now = rightNow();
		items.refetch();
	});

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
{#if $items.loading}
    Loading...
{:else if $items.error}
    Error: {$items.error.message}
{:else}
    <SimpleGrid cols={4} 
        breakpoints={[
            { maxWidth: 980, cols: 3, spacing: 'md' },
            { maxWidth: 755, cols: 2, spacing: 'sm' },
            { maxWidth: 600, cols: 1, spacing: 'sm' }
        ]}>
        {#each $items.data.itemAll as item}
            {#if availability}
                {#if checkAvailability(item, now)}
                    {#if (checkSearch(item, search) && checkInducted(item, inducted, upi))}                
                        <ItemObj {item} {bookItem} {showItem} {loggedIn} {upi} available={true}/>
                    {/if}
                {/if}
            {:else}
                {#if (checkSearch(item, search) && checkInducted(item, inducted, upi))}                
                    <ItemObj {item} {bookItem} {showItem} {loggedIn} {upi} available={checkAvailability(item, now)}/>
                {/if}
            {/if}
        {/each}
    </SimpleGrid>
{/if}
<!----------------------------------------------------------------------------------------------------->

<!--

if the availability button is false, we show all items depending on search and inducted and we change the colour of the button depending on availability

If the availability button is true, we also take into account whether the item is available or not


-->