<!------------------------------------------------------------------------------------------------------
  A simple navbar
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { SimpleGrid, Box, Center, Button, Input, InputWrapper, TextInput, Divider, Switch, Space, Text, Group, Checkbox } from '@svelteuidev/core';
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
        <Text root='p' size='lg' align='center' weight={'bold'}>{getName(appVars.item.details, appVars.item.name)}</Text>
    {/if}

    <Center><Button on:click={loginPressed} variant='light' color='{loggedIn?"red":"blue"}'>
        <LockClosed slot="rightIcon" />
        Log {loggedIn?"out " + appVars.session.person.name:"in"}
    </Button></Center><br/>
</Box>

<Divider variant='dotted'/>
<b>{appVars.message}</b>
<Divider variant='dotted'/>

{#if (appState === AppStates.MAIN_LIST)}
    <SimpleGrid spacing="xs" cols={2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <SimpleGrid spacing="xs" cols={loggedIn?3:2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
            <Group position="center">
                <TextInput bind:value={searchString} icon={MagnifyingGlass} placeholder='Filter by' rightSectionWidth={70}/>
            </Group>
            <Group position="center">
                <Checkbox color="gray" bind:checked={availability}/>&nbsp;<b>available</b>
            </Group>
            {#if loggedIn}
                <Group position="center">
                    <Checkbox color="gray" bind:checked={inducted}/>&nbsp;<b>bookable</b>
                </Group>
            {/if}
        </SimpleGrid>
        <Group position="center"><b>grid</b>&nbsp;<Switch color='blue' bind:checked={list} />&nbsp;<b>list</b></Group>
    </SimpleGrid>
{:else if (appState === AppStates.MAIN_BOOKING)}
    <SimpleGrid cols={2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneBooking} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            List of Items
        </Button>
        <Button on:click={showDetails} variant="light" color="blue">
            Details
        </Button>
    </SimpleGrid>
{:else if (appState === AppStates.MAIN_DETAILS)}
    <SimpleGrid cols={2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneDetails} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            Bookings
        </Button>
    </SimpleGrid>
{:else if (appState === AppStates.ITEM_DETAILS)}
    <SimpleGrid cols={2} breakpoints={[ { maxWidth: 600, cols: 1, spacing: 'sm' } ]}>
        <Button on:click={doneDetails} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            List of Items
        </Button>
    </SimpleGrid>
{/if}
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->