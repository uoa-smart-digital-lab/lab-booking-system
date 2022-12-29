<!------------------------------------------------------------------------------------------------------
An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck

	import { Container, Checkbox } from '@svelteuidev/core';
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import Calendar from '@event-calendar/core';
    import DayGrid from '@event-calendar/day-grid';
    import List from '@event-calendar/list';
    import TimeGrid from '@event-calendar/time-grid';
    import ResourceTimeGrid from '@event-calendar/resource-time-grid';

    export let itemname;            // Details about the item itself
    export let daybooking;          // Month or Day view

    let plugins = [TimeGrid, DayGrid, List, ResourceTimeGrid];
    let events = [];
    let options = {
        view: (daybooking)?'dayGridMonth':'timeGridWeek',
        events: events
    }

    $: options.view = (daybooking)?'dayGridMonth':'timeGridWeek';

    let item = query(ITEMGET, {
      variables: {name: itemname}
    });

    function getname (details, name) {
        return (details.name ? details.name : name);
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
{#if $item.loading}
    Loading...
{:else if $item.error}
    Error: {$item.error.message}
{:else}
    <Calendar {plugins} {options} {daybooking}/>
{/if}
<!----------------------------------------------------------------------------------------------------->
