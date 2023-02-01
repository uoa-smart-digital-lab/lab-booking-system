<!------------------------------------------------------------------------------------------------------
  All the items in the system
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { query } from 'svelte-apollo';
    import ItemButton from './ItemButton.svelte';
	import { SimpleGrid, Button } from '@svelteuidev/core';
    import { ITEMALL } from './Graphql.svelte';
    import type { Item, ItemDetails, Person, Booking } from './Graphql.svelte';
    import { beforeUpdate } from 'svelte';

    import { RevoGrid } from "@revolist/svelte-datagrid";


    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    // export let searchString : string;               // A string to match against to show only the items being searched for.
    // export let loggedIn : boolean;                  // Whether a user is logged in or not
    // export let upi : string;                        // Currently logged in user's UPI
    // export let inducted : boolean;                  // Whether to show only items the user is inducted for, or all items.
    // export let availability : boolean;              // Whether to show only items that are currently available for booking.
    // export let qrcode: boolean;
    // export let list: boolean;
    
    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let now: Date;

    let grid: any;

    function data (graphqlData: any) {
        let returnData = [];
        graphqlData.forEach(element => {
            returnData.push({nicename: getname(element.details), name:element.name, url:element.url, image:element.image, bookable:element.bookable?"TRUE":"FALSE", cost:element.cost, access:element.access})
        });
        console.log(returnData);
        return returnData;
    }


    let source = [
        {
            prop: "name",
            name: "First",
        },
        {
            prop: "details",
            name: "Second",
        }
    ];
    let columns = [
        {
            name: "1",
            details: "Item 1",
        }
    ];

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // The GraphQL query structure for login
    const items : any = query(ITEMALL, { variables: {} });

    // Force reload of the data
    function reload () { items.refetch(); }

    // Get the name from the details if it exists, otherwise return an empty string rather than undefined
    function getname (details : ItemDetails) : string { return(details.name ? details.name : ""); }

    // Check whether the search string is in the name of the item or the details.name of the item. Or if the search string is empty, return true.
    const checkSearch = (item : Item, searchString : string) : boolean => 
        (item.bookable && (item.name.includes(searchString.toLowerCase()) || getname(item.details).includes(searchString.toLowerCase()) || (searchString === "")));

    // Check whether the person can book the item.  Either it is free to use (so return true) or the user must be inducted, in which case they must be named in the inducted list to return true
    const checkInducted = (item : Item, inducted : boolean, upi : string) : boolean => 
        ((item.access.toString() === "FREE") ? true : ((item.access.toString() === "INDUCTION") ? (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), !inducted)) : !inducted));

    // Check whether the given time is between the start and end times.
    const timeOverlaps = (startTime : Date, endTime : Date, testTime : Date) : boolean => (testTime >= startTime && testTime <= endTime);

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
    revo-grid {
	    height: 100%;
	}
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
    <RevoGrid source={[
        {
            prop: "name",
            name: "First",
        },
        {
            prop: "details",
            name: "Second",
        }
    ]} resize="true" columns={[
        {
            name: "1",
            details: "Item 1",
        }
    ]}/>


    <!-- <RevoGrid
        resize="true" 
        columns={[{
            prop:"nicename",
            name: "Name"
        }, {
            prop:"name",
            name: "ID"
        }, {
            prop: "url",
            name: "URL"
        }, {
            prop: "image",
            name: "Image"
        }, {
            prop: "bookable",
            name: "Bookable"
        }, {
            prop: "cost",
            name: "Cost"
        }, {
            prop: "access",
            name: "Access"
        }]}
        source={data($items.data.itemAll)} /> -->
{/if}

<!----------------------------------------------------------------------------------------------------->