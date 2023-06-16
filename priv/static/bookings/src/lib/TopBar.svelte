<!------------------------------------------------------------------------------------------------------
  Menu top bar for navigation and control of the Web App

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { reload, Button, Buttons, Icon, Input, Menu, Item, Checkbox, Dropdown, Text } from "svelte-fomantic-ui";
    import { AppStates, AppEvents, LoginStates, LoginEvents } from './Types.svelte';
    import Navigator from "./Navigator.svelte";
    import type { AppVars } from './Types.svelte';

    export let numCols : number;
    export let loggedIn : boolean;
    export let LoginC : any;
    export let list : boolean;
    export let availability : boolean;
    export let inducted : boolean;
    export let searchString : string;
    export let AppC : any;
    export let appVars: AppVars;

    let prevNumCols : number = -1;

    // -------------------------------------------------------------------------------------------------
    // Call the $("#dropdown_menu").dropdown() function on the dropdown menu once it has been made visible
    // This refreshes and reactivates the code
    // -------------------------------------------------------------------------------------------------
    $: if (prevNumCols !== numCols) { prevNumCols = numCols; setTimeout(() => {reload("dropdown_menu");}, 1000) }
    // -------------------------------------------------------------------------------------------------

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
{#if numCols<=2}
    <Menu ui top fixed>
        <Item>
            <Navigator {AppC} {numCols} on:showDetails item={appVars.item}/> <!-- name={(AppC.currentState === AppStates.MAIN_LIST)?"":appVars?(appVars.item?appVars.item.name:""):""}/> -->
        </Item>
        <Menu right>
            <Item>
                <Dropdown ui icon button left pointing settings={{showOnFocus:true}} id="dropdown_menu">
                    <Icon black ellipsis vertical/>
                    <Menu ui vertical>
                        <Item>
                            <Button ui fluid _={loggedIn?"orange":"blue"} on:click={()=>{if (loggedIn) {LoginC.step(LoginEvents.LOG_OUT)} else {LoginC.step(LoginEvents.OPEN_DIALOG)}}}>
                                <Icon user/>
                                Log {loggedIn?"out":"in"}
                            </Button>
                        </Item>
                        {#if (AppC.currentState === AppStates.MAIN_LIST)}
                            <Item>
                                <center>
                                    <Buttons ui centered>
                                        <Button ui icon _={list?"green":"grey"} on:click={()=>list=true}>
                                            <Icon list/>
                                        </Button>
                                        <Button ui icon _={!list?"green":"grey"} on:click={()=>list=false}>
                                            <Icon th/>
                                        </Button>
                                    </Buttons>
                                </center>
                            </Item>
                            <Item>
                                <center>
                                    <Checkbox ui right aligned toggle fluid label="Available" bind:checked={availability}/>
                                </center>
                            </Item>
                            <Item>
                                <center>
                                    <Checkbox ui right aligned toggle fluid label="Inducted" bind:checked={inducted}/>
                                </center>
                            </Item>
                            <Item>
                                <Input ui small>
                                    <input placeholder="Search..." type="text" on:click|stopPropagation bind:value={searchString}/>
                                </Input>
                            </Item>
                        {/if}
                    </Menu>
                </Dropdown>
            </Item>
        </Menu>
    </Menu>
{:else}
    <Menu ui mini top fixed stackable>
        <Item>
            <Button ui fluid _={loggedIn?"orange":"blue"} on:click={()=>{if (loggedIn) {LoginC.step(LoginEvents.LOG_OUT)} else {LoginC.step(LoginEvents.OPEN_DIALOG)}}}>
                <Icon user/>
                Log {loggedIn?"out":"in"}
            </Button>
        </Item>
        <Item>
            <Navigator {AppC} {numCols} on:showDetails item={appVars.item}/> <!-- name={(AppC.currentState === AppStates.MAIN_LIST)?"":appVars?(appVars.item?appVars.item.name:""):""}/> -->
        </Item>

        {#if (AppC.currentState === AppStates.MAIN_LIST)}
            <Menu right mini>
                <Item>
                    <Buttons ui mini>
                        <Button ui icon _={list?"green":"grey"} on:click={()=>list=true}>
                            <Icon list/>
                        </Button>
                        <Button ui icon _={!list?"green":"grey"} on:click={()=>list=false}>
                            <Icon th/>
                        </Button>
                    </Buttons>
                </Item>
                <Item>
                    <Checkbox ui right aligned toggle fluid label="Available" bind:checked={availability}/>
                </Item>
                <Item>
                    <Checkbox ui right aligned toggle fluid label="Inducted" bind:checked={inducted}/>
                </Item>
                <Item>
                    <Input ui>
                        <Input text bind:value={searchString} placeholder="Search..."/>
                    </Input>
                </Item>
            </Menu>
        {/if}
    </Menu>
{/if}
<!----------------------------------------------------------------------------------------------------->
