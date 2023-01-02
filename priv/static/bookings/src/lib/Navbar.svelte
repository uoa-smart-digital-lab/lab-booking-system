<!------------------------------------------------------------------------------------------------------
  A simple navbar
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { SimpleGrid, Box, Center, Button, Input, Divider, Switch } from '@svelteuidev/core';
    import { MagnifyingGlass } from 'radix-icons-svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let loggedIn : boolean;                                      // Whether the user is presently logged in or not
    export let name : string;                                           // The logged in user's name
    export let itemName : string;                                       // The current item being investigated
    export let availability : boolean;                                  // Current value for availability checkbox
    export let inducted : boolean;                                      // Current value for inducted checkbox
    export let context : string;                                        // Current value for context checkbox
    export let search : string;                                         // Current value for search field
    export let message : string;                                        // A message to show under the bar
    export let doLoginOrLogout : () => void;                            // Function to call when log in button pressed
    export let cancelBooking : () => void;                              // Go back to the main app
    export let doneDetails : () => void;                                // Go back to the main app
    export let changeVar : (name: string, newvalue: any) => void;       // Change variable in the main app

    const changeAvailability = (event:any) : void => { changeVar("availability", event.target.checked); }
    const changeInducted = (event:any) : void => { changeVar("inducted", event.target.checked); }
    const changeSearch = (event:any) : void => { changeVar("search", event.target.value); }
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
<Box
    css={{
        backgroundColor: '$dark100',
        textAlign: 'center',
        padding: '3px',
        paddingTop: '6px',
        borderRadius: '$sm'
    }}>
    <h2>Smart Digital Lab</h2>
    {#if itemName}<h3>{itemName}</h3>{/if}
    {#if name}<h4>{name}</h4>{/if}
</Box>
<Divider variant='dotted'/>
<b>{message}</b>
<Divider variant='dotted'/>
<SimpleGrid cols={2} 
    breakpoints={[
        { maxWidth: 600, cols: 1, spacing: 'sm' }
    ]}>
    {#if context === "main"}
        <Input
            icon={MagnifyingGlass}
            placeholder='Refine'
            rightSectionWidth={70}
            on:input={changeSearch}
            bind:value={search}
        />
        <Button on:click={doLoginOrLogout} variant='light' color='{loggedIn?"red":"blue"}'>
            Log {loggedIn?"out":"in"}
        </Button>
        <Center><Switch label="Available now" color="gray" on:click={changeAvailability} bind:checked={availability} /></Center>
        {#if loggedIn}       
            <Center><Switch label="Allowed to book" color="gray" on:click={changeInducted} bind:checked={inducted}/></Center>
        {/if}
    {:else if context === "details"}
        <Button on:click={doneDetails} variant='light' color='green'>
            Item List
        </Button>
        <Button on:click={doLoginOrLogout} variant='light' color='{loggedIn?"red":"blue"}'>
            Log {loggedIn?"out":"in"}
        </Button>
    {:else}
        <Button on:click={cancelBooking} variant='light' color='green'>
            Item List
        </Button>
        <Button on:click={doLoginOrLogout} variant='light' color='{loggedIn?"red":"blue"}'>
            Log {loggedIn?"out":"in"}
        </Button>
    {/if}
</SimpleGrid>
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->