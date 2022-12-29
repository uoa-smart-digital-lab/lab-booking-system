<!------------------------------------------------------------------------------------------------------
All the items in the system
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck

    import { query } from 'svelte-apollo';
    import Item from './Item.svelte';
	import { SimpleGrid } from '@svelteuidev/core';
    import { ITEMALL } from './Graphql.svelte';

    export let search;          // A string to match against to show only the items being searched for.
    export let loggedin;        // Whether a user is logged in or not
    export let upi;             // Currently logged in user's UPI
    export let inducted;        // Whether to show only items the user is inducted for, or all items.
    export let availability;    // Whether to show only items that are currently available for booking. (TODO)
    
    export let doneloading;     // A Function to call when the full list has been loadded, to signal to the calling object.
    export let bookitem;        // A function to call when a specific item is to be booked.

    let items = query(ITEMALL, {
      variables: {}
    });

    const reload = () => { items.refetch(); }
    const getname = (details) => (details.name ? details.name : "");
    const checkSearch = (item, search) => (item.bookable && (item.name.includes(search.toLowerCase()) || getname(item.details).includes(search.toLowerCase()) || (search === "")));
    const checkInducted = (item, inducted, upi) => ((item.access === "FREE") ? true : ((item.access === "INDUCTION") ? (item.inductions.reduce((acc, curr) => acc || (curr.upi === upi), !inducted)) : !inducted));

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
    {doneloading()}
    <SimpleGrid cols={4} 
        breakpoints={[
            { maxWidth: 980, cols: 3, spacing: 'md' },
            { maxWidth: 755, cols: 2, spacing: 'sm' },
            { maxWidth: 600, cols: 1, spacing: 'sm' }
        ]}>
        {#each $items.data.itemAll as item}
            {#if (checkSearch(item, search) && (checkInducted(item, inducted, upi)))}
                    <Item item={item} bookitem={bookitem} loggedin={loggedin}/>
            {/if}  
        {/each}
    </SimpleGrid>
{/if}
<!----------------------------------------------------------------------------------------------------->