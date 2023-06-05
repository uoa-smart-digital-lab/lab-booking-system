<!------------------------------------------------------------------------------------------------------
  Web App Navigator

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Icon, Breadcrumb, Link } from "svelte-fomantic-ui";
    import { AppStates, AppEvents } from './Types.svelte';

    export let AppC : any;

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
        <Link section on:click={()=>AppC.step(AppEvents.SHOW_LIST)}>
            <Icon list/>
            List
        </Link>
    {/if}
    {#if (AppC.currentState === AppStates.MAIN_BOOKING) || (AppC.currentState === AppStates.MAIN_DETAILS)}
        <Icon right chevron divider/>
        <Link section on:click={()=>AppC.step(AppEvents.SHOW_BOOKING)}>
            <Icon calendar alternate outline/>
            Booking
        </Link>
    {/if}
    {#if (AppC.currentState === AppStates.ITEM_DETAILS) || (AppC.currentState === AppStates.MAIN_DETAILS)}
        <Icon right chevron divider/>
        <Link section>
            <Icon info/>
            Details
        </Link>
    {/if}
</Breadcrumb>
<!----------------------------------------------------------------------------------------------------->