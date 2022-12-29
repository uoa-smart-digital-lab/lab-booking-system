<!------------------------------------------------------------------------------------------------------
A simple navbar
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck
	import { SimpleGrid, Box, Checkbox, Button, Input, Divider, Space } from '@svelteuidev/core';
    import { MagnifyingGlass } from 'radix-icons-svelte';

    export let dologin;             // Function to call when log in button pressed
    export let cancelbooking;       // Go back to the main app
    export let changevar;           // Change variable in the main app
    export let loggedin;            // Whether the user is presently logged in or not
    export let name;                // The logged in user's name
    export let itemname;            // The current item being investigated
    export let availability;        // Current value for availability checkbox
    export let inducted;            // Current value for inducted checkbox
    export let context;             // Current value for context checkbox
    export let daybooking;          // Current value for daybooking checkbox
    export let search;              // Current value for search field

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
    <h2>Smart Digital Lab{name?" | "+name:""}{itemname?" | "+itemname.toUpperCase():""}</h2>
</Box>
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
            styles={{ rightSection: { pointerEvents: 'none' } }}
            on:input={(event) => {changevar("search", event.target.value); }}
            value={search}
        />
        <Checkbox label="Available now" color="gray" on:click={(event) => { changevar("availability", event.target.checked); }} bind:checked={availability} />
        <Checkbox label="Allowed to book" color="gray" on:click={(event) => { changevar("inducted", event.target.checked); }} disabled={!loggedin} bind:checked={inducted}/>
        <Button on:click={dologin} variant='light' color='{loggedin?"red":"blue"}'>
            Log {loggedin?"out":"in"}
        </Button>
    {:else}
        <Button on:click={cancelbooking} variant='light' color='green'>
            Item List
        </Button>
        <Checkbox label="Whole day booking" color="gray" on:click={(event) => { changevar("daybooking", event.target.checked); }} bind:checked={daybooking} />
        <Space />
        <Button on:click={dologin} variant='light' color='{loggedin?"red":"blue"}'>
            Log {loggedin?"out":"in"}
        </Button>
    {/if}
</SimpleGrid>
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->