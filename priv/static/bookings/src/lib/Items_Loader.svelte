<!------------------------------------------------------------------------------------------------------
  All the items in the database

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { query } from 'svelte-apollo';
    import { ITEMALL } from './Graphql.svelte';
    import { beforeUpdate } from 'svelte';
    import Items from "./Items.svelte";

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let searchString : string;               // A string to match against to show only the items being searched for.
    export let loggedIn : boolean;                  // Whether a user is logged in or not
    export let upi : string;                        // Currently logged in user's UPI
    export let inducted : boolean;                  // Whether to show only items the user is inducted for, or all items.
    export let availability : boolean;              // Whether to show only items that are currently available for booking.
    export let qrcode: boolean;
    export let list: boolean;
    export let numCols: number;
    export let queryVars: {};
    
    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // The GraphQL query structure for login
    const items : any = query(ITEMALL, { variables: {} });

    // Force reload of the data
    function reload () { items.refetch(); }

    // Get the current time and refetch the items
    beforeUpdate(() => {
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
    Loading ...
{:else if $items.error}
    Error: {$items.error.message}
{:else}
    <Items on:book on:showDetails {numCols} {list} {searchString} {loggedIn} {upi} {inducted} {availability} {qrcode} items={$items.data.itemAll}/>
{/if}
<!----------------------------------------------------------------------------------------------------->