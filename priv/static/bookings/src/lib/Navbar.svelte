<!------------------------------------------------------------------------------------------------------
  A simple navbar
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { SimpleGrid, Box, Center, Button, Input, Divider, Switch, Space } from '@svelteuidev/core';
    import { MagnifyingGlass } from 'radix-icons-svelte';
    import { LockClosed, ArrowLeft } from 'radix-icons-svelte';
    import type { Item, ItemDetails } from './Graphql.svelte';
    import type { QueryVars, AppVars } from './Types.svelte';
    import { AppStates, AppEvents, LoginStates } from './Types.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    // export let loggedIn : boolean;                                      // Whether the user is presently logged in or not
    // export let name : string;                                           // The logged in user's name
    // export let item : Item;                                             // The current item being investigated
    // export let availability : boolean;                                  // Current value for availability checkbox
    // export let inducted : boolean;                                      // Current value for inducted checkbox
    // export let context : string;                                        // Current value for context checkbox
    // export let search : string;                                         // Current value for search field
    // export let message : string;                                        // A message to show under the bar

    export let updater : number;
    export let appState : AppStates;
    export let loginState : LoginStates;
    export let appVars : AppVars;
    export let queryVars : QueryVars;

    export let doLoginOrLogout : () => void;                            // Function to call when log in button pressed
    export let cancelBooking : () => void;                              // Go back to the main app
    export let changeVar : (name: string, newvalue: any) => void;       // Change variable in the main app
    export let showItem : (url : string) => void;                       // The function to call when the item details button is pressed
    export let doneDetails : () => void;                                // Done showing the current Item Details

    // const changeAvailability = (event:any) : void => { changeVar("availability", event.target.checked); }
    // const changeInducted = (event:any) : void => { changeVar("inducted", event.target.checked); }
    const changeSearch = (event:any) : void => { queryVars.search = event.target.value }; //changeVar("search", event.target.value); }

    const getName = (details : ItemDetails, name : string) : string => details.name ? details.name + " (" + name.toUpperCase() + ")" : name.toUpperCase();
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
    css={{
        backgroundColor: '$blue200',
        textAlign: 'center',
        padding: '3px',
        paddingTop: '6px',
        borderRadius: '$sm'
    }}>
    <img src="/images/logo.png" alt="logo"/>
    {#if appVars.item}
        <h3>{getName(appVars.item.details, appVars.item.name)}</h3>
    {/if}
    {#if appVars.session}<h4>{appVars.session.person.name}</h4>{/if}
</Box>

<Divider variant='dotted'/>
<b>{appVars.message}</b>
<Divider variant='dotted'/>

<SimpleGrid cols={(appState === AppStates.MAIN_LIST)?2:3} 
    breakpoints={[
        { maxWidth: 600, cols: 1, spacing: 'sm' }
    ]}>
    {#if (appState === AppStates.MAIN_LIST)}
        <Input
            icon={MagnifyingGlass}
            placeholder='Refine'
            rightSectionWidth={70}
            on:input={changeSearch}
            bind:value={queryVars.search}
        />
        <Button on:click={doLoginOrLogout} variant='light' color='{(loginState === LoginStates.LOGGED_IN)?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {(loginState === LoginStates.LOGGED_IN)?"out":"in"}
        </Button>
        <!-- <Center><Switch label="Currently available" color="gray" on:click={changeAvailability} bind:checked={availability} /></Center>
        {#if (loginState === LoginStates.LOGGED_IN)}       
            <Center><Switch label="Items I can book" color="gray" on:click={changeInducted} bind:checked={inducted}/></Center>
        {/if} -->
    {:else if (appVars.item && (appState === AppStates.MAIN_DETAILS))}
        <Button on:click={doneDetails} variant='light' color='blue'>
            <ArrowLeft slot="leftIcon" />
            Bookings
        </Button>
        <Space />
        <Button on:click={doLoginOrLogout} variant='light' color='{(loginState === LoginStates.LOGGED_IN)?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {(loginState === LoginStates.LOGGED_IN)?"out":"in"}
        </Button>
    {:else}
        <Button on:click={cancelBooking} variant='light' color='green'>
            <ArrowLeft slot="leftIcon" />
            List of Items
        </Button>
        {#if appState === AppStates.MAIN_DETAILS}
            <Button on:click={() => {showItem(appVars.item.url)}} variant="light" color="blue">
                Details
            </Button>
        {:else}
            <Space />
        {/if}
        <Button on:click={doLoginOrLogout} variant='light' color='{(loginState === LoginStates.LOGGED_IN)?"red":"blue"}'>
            <LockClosed slot="rightIcon" />
            Log {(loginState === LoginStates.LOGGED_IN)?"out":"in"}
        </Button>
    {/if}
</SimpleGrid>
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->