<!------------------------------------------------------------------------------------------------------
A simple navbar
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck
	import { SimpleGrid, Box, Checkbox, Button, Input, Divider, Space } from '@svelteuidev/core';
    import { MagnifyingGlass } from 'radix-icons-svelte';

    export let dologin;             // Function to call when log in button pressed
    export let changesearch;        // Function to call when the search text changes (send text as parameter)
    export let loggedin;            // Whether the user is presently logged in or not
    export let changeavailability;  // Function to call when 'available now' setting is changed
    export let changeinducted;      // Function to call when 'inducted' setting is changed
    export let changedaybooking;    // Function to call when 'daybooking' setting is changed
    export let name;                // The logged in user's name
    export let itemname;            // The current item being investigated
    export let availability;
    export let inducted;
    export let context;
    export let daybooking;

    function inputchanged(event) {
        changesearch(event.target.value);
    }
    function availabilitychanged(event) {
        changeavailability(event.target.checked);
    }
    function inductedchanged(event) {
        changeinducted(event.target.checked);
    }
    function daybookingchanged(event) {
        console.log("HERE");
        changedaybooking(event.target.checked);
    }


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
        padding: '5px',
        paddingTop: '10px',
        borderRadius: '$md'
    }}>
    <h2>Smart Digital Lab{name?" | "+name:""}{itemname?" | "+itemname:""}</h2>
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
            on:input={inputchanged}
        />
        <Checkbox label="Available now" color="gray" on:click={availabilitychanged} bind:checked={availability} />
        <Checkbox label="Allowed to book" color="gray" on:click={inductedchanged} disabled={!loggedin} bind:checked={inducted}/>
        <Button on:click={dologin} variant='light' color='{loggedin?"red":"blue"}'>
            Log {loggedin?"out":"in"}
        </Button>
    {:else}
        <Button on:click={dologin} variant='light' color='green'>
            Cancel
        </Button>
        <Checkbox label="Whole day booking" color="gray" on:click={daybookingchanged} bind:checked={daybooking} />
        <Space />
        <Button on:click={dologin} variant='light' color='{loggedin?"red":"blue"}'>
            Log {loggedin?"out":"in"}
        </Button>
    {/if}
</SimpleGrid>
<Divider variant='dotted'/>
<!----------------------------------------------------------------------------------------------------->