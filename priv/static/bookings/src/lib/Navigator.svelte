<!------------------------------------------------------------------------------------------------------
  Web App Navigator

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Icon, Breadcrumb, Link, Section, Text } from "svelte-fomantic-ui";
    import { AppStates, AppEvents } from './Types.svelte';
	import { createEventDispatcher } from 'svelte';
    import type { Item as ItemT} from './Graphql.svelte';

    export let AppC : any;
    export let numCols : number;
    export let item : ItemT                         // Details about the item

    const dispatch = createEventDispatcher();

    function showDetails () { dispatch ( 'showDetails', { item : item } ) }

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
<Breadcrumb ui>
    {#if (AppC.currentState === AppStates.MAIN_BOOKING) || (AppC.currentState === AppStates.MAIN_DETAILS) || (AppC.currentState === AppStates.ITEM_DETAILS) || (AppC.currentState === AppStates.MAIN_LIST)}
        {#if (AppC.currentState !== AppStates.MAIN_LIST)}
            <Link section on:click={()=>AppC.step(AppEvents.SHOW_LIST)}>
                <Icon list/>
                {#if numCols > 1}
                    List
                {/if}
            </Link>
        {:else}
            <Section>
                <Icon list black/>
                {#if numCols > 1}
                    <Text ui black>List</Text>
                {/if}
            </Section>
        {/if}
    {/if}
    {#if (AppC.currentState === AppStates.MAIN_BOOKING) || (AppC.currentState === AppStates.MAIN_DETAILS)}
        <Icon right chevron divider/>
        {#if (AppC.currentState === AppStates.MAIN_DETAILS)}
            <Link section on:click={()=>AppC.step(AppEvents.SHOW_BOOKING)}>
                <Icon calendar alternate outline/>
                {#if numCols > 1}
                    Booking
                {/if}
            </Link>
        {:else}
            <Section>
                <Icon calendar alternate outline black/>
                {#if numCols > 1}
                    <Text ui black>Booking</Text>
                {/if}
            </Section>
        {/if}
    {/if}
    {#if (AppC.currentState === AppStates.ITEM_DETAILS) || (AppC.currentState === AppStates.MAIN_DETAILS)}
        <Icon right chevron divider/>
        <Section>
            <Icon info black/>
            {#if numCols > 1}
                <Text ui black>Info</Text>
            {/if}
        </Section>
    {/if}
    {#if item && item.name !== ""}
        {#if (AppC.currentState === AppStates.MAIN_BOOKING)}
            <Link section on:click={showDetails}>
                <Icon grip lines vertical divider />
                <Section>{item.name.toUpperCase()}</Section>
            </Link>
        {:else}
            <Icon grip lines vertical divider/>
            <Section><Text ui black>{item.name.toUpperCase()}</Text></Section>
        {/if}
    {/if}
</Breadcrumb>
<!----------------------------------------------------------------------------------------------------->