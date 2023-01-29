<!------------------------------------------------------------------------------------------------------
  A simple navbar
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { SimpleGrid, Box, Center, Button, Input, Divider, Switch, Space } from '@svelteuidev/core';
    import { MagnifyingGlass } from 'radix-icons-svelte';
    import { LockClosed, ArrowLeft } from 'radix-icons-svelte';
    import type { ItemDetails, Item } from './Graphql.svelte';
    import type { QueryVars, AppVars } from './Types.svelte';
    import { AppStates } from './Types.svelte';
	import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------

    export let appState : AppStates;
    export let appVars : AppVars;
    export let queryVars : QueryVars;

    export let loggedIn : boolean;                                      // Whether the user is presently logged in or not
    export let searchString : string;                                   // The search string to refine the search for items
    export let availability : boolean;
    export let inducted : boolean;
    export let list : boolean;

    // Send a message to the App that the login / logout button has been pressed.
    function loginPressed () { dispatch ( 'login', { message : (loggedIn ? 'logout' : 'login'), data : {} } ) }

    // Finished with the booking panel
    function doneBooking () { dispatch ( 'doneBooking', { } ) }

    // Create a string to display with the item name and the details.name if it exists.
    function getName (details : ItemDetails, name : string) : string { return (details.name ? details.name + " (" + name.toUpperCase() + ")" : name.toUpperCase()); }

    // Show and stop showing the Details for an item
    function showDetails () { dispatch ( 'showDetails', { item : appVars.item } ) }
    function doneDetails () { dispatch ( 'doneDetails', { } ) }

    // If there was a search query string entered, use it here.
    if (queryVars.search) searchString = queryVars.search;

</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>
    img {
        width: 100%;
        max-width: 400px;
        height: auto;
      }
</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Box
    css={{ backgroundColor: '$yellow400', textAlign: 'center', padding: '3px', paddingTop: '6px', borderRadius: '$sm' }}>
    <img src="/images/logo.png" alt="logo"/>
    {#if appVars.item}
        <h3>{getName(appVars.item.details, appVars.item.name)}</h3>
    {/if}
    {#if loggedIn}
        <h4>{appVars.session.person.name}</h4>
    {:else}
        <h4>[ Please log in ]</h4>
    {/if}
</Box>

<Divider variant='dotted'/>
<b>{appVars.message}</b>
<Divider variant='dotted'/>

{#if (appState === AppStates.MAIN_LIST)}
    <SimpleGrid cols={2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Input bind:value={searchString} icon={MagnifyingGlass} placeholder='Refine' rightSectionWidth={70}/>
        <Button on:click={loginPressed} variant='light' color='{loggedIn?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {loggedIn?"out":"in"}
        </Button>
    </SimpleGrid>
    <Divider variant='dotted'/>
    <SimpleGrid cols={3} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Center><b>grid</b>&nbsp;<Switch color='blue' bind:checked={list} />&nbsp;<b>list</b></Center>
        <Center><Switch bind:checked={availability} />&nbsp;<b>available</b></Center>
        {#if loggedIn}       
            <Center><b>all</b>&nbsp;<Switch bind:checked={inducted}/>&nbsp;<b>bookable</b></Center>
        {/if}
    </SimpleGrid>
{:else if (appState === AppStates.MAIN_BOOKING)}
    <SimpleGrid cols={3} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneBooking} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            List of Items
        </Button>
        <Button on:click={showDetails} variant="light" color="blue">
            Details
        </Button>
        <Button on:click={loginPressed} variant='light' color='{loggedIn?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {loggedIn?"out":"in"}
        </Button>
    </SimpleGrid>
{:else if (appState === AppStates.MAIN_DETAILS)}
    <SimpleGrid cols={3} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneDetails} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            Bookings
        </Button>
        <Space />
        <Button on:click={loginPressed} variant='light' color='{loggedIn?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {loggedIn?"out":"in"}
        </Button>
    </SimpleGrid>
{:else if (appState === AppStates.ITEM_DETAILS)}
    <SimpleGrid cols={3} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneDetails} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            List of Items
        </Button>
        <Space />
        <Button on:click={loginPressed} variant='light' color='{loggedIn?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {loggedIn?"out":"in"}
        </Button>
    </SimpleGrid>
{/if}
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->