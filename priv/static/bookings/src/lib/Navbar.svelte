<!------------------------------------------------------------------------------------------------------
  A simple navbar
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { SimpleGrid, Box, Checkbox, Button, Input, Divider, Space } from '@svelteuidev/core';
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
    <h2>Smart Digital Lab{name?" | "+name:""}{itemName?" | "+itemName.toUpperCase():""}</h2>
</Box>
<Divider variant='dotted'/>
<b>{message}</b>
<Divider variant='dotted'/>
<SimpleGrid cols={4} 
    breakpoints={[
        { maxWidth: 980, cols: 3, spacing: 'md' },
        { maxWidth: 755, cols: 2, spacing: 'sm' },
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
        <!-- <Checkbox label="Available now" color="gray" on:click={(event) => { changeVar("availability", event.target.checked); }} bind:checked={availability} />
        <Checkbox label="Allowed to book" color="gray" on:click={(event) => { changeVar("inducted", event.target.checked); }} disabled={!loggedIn} bind:checked={inducted}/> -->
        <Checkbox label="Available now" color="gray" on:click={changeAvailability} bind:checked={availability} />
        {#if loggedIn}       
            <Checkbox label="Allowed to book" color="gray" on:click={changeInducted} bind:checked={inducted}/>
        {:else}
            <Space />
        {/if}
        <Button on:click={doLoginOrLogout} variant='light' color='{loggedIn?"red":"blue"}'>
            Log {loggedIn?"out":"in"}
        </Button>
    {:else}
        <Button on:click={cancelBooking} variant='light' color='green'>
            Item List
        </Button>
        <Space />
        <Space />
        <Button on:click={doLoginOrLogout} variant='light' color='{loggedIn?"red":"blue"}'>
            Log {loggedIn?"out":"in"}
        </Button>
    {/if}
</SimpleGrid>
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->