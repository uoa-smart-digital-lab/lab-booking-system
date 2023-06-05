<!------------------------------------------------------------------------------------------------------
  Menu top bar for navigation and control of the Web App

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { reload, Button, Buttons, Icon, Input, Menu, Item, Checkbox, Dropdown, Breadcrumb, Link } from "svelte-fomantic-ui";
    import { AppStates, AppEvents, LoginStates, LoginEvents } from './Types.svelte';
    import Navigator from "./Navigator.svelte";

    export let numCols : number;
    export let loggedIn : boolean;
    export let LoginC : any;
    export let list : boolean;
    export let availability : boolean;
    export let inducted : boolean;
    export let searchString : string;
    export let AppC : any;

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
    <Menu ui small top fixed>
        <Item>
            <Navigator bind:AppC/>
        </Item>
        <Menu right small>
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
                                    <Checkbox ui right aligned toggle fluid label="Bookable" bind:checked={availability}/>
                                </center>
                            </Item>
                            <Item>
                                <center>
                                    <Checkbox ui right aligned toggle fluid label="Inducted" bind:checked={inducted}/>
                                </center>
                            </Item>
                            <Item ui right aligned category search>
                                <Input ui>
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
    <Menu ui small top fixed stackable>
        <Item>
            <Button ui fluid _={loggedIn?"orange":"blue"} on:click={()=>{if (loggedIn) {LoginC.step(LoginEvents.LOG_OUT)} else {LoginC.step(LoginEvents.OPEN_DIALOG)}}}>
                <Icon user/>
                Log {loggedIn?"out":"in"}
            </Button>
        </Item>
        <Item>
            <Navigator bind:AppC/>
        </Item>

        {#if (AppC.currentState === AppStates.MAIN_LIST)}
            <Menu right small>
                <Item>
                    <Buttons ui>
                        <Button ui icon _={list?"green":"grey"} on:click={()=>list=true}>
                            <Icon list/>
                        </Button>
                        <Button ui icon _={!list?"green":"grey"} on:click={()=>list=false}>
                            <Icon th/>
                        </Button>
                    </Buttons>
                </Item>
                <Item>
                    <Checkbox ui right aligned toggle fluid label="Bookable" bind:checked={availability}/>
                </Item>
                <Item>
                    <Checkbox ui right aligned toggle fluid label="Inducted" bind:checked={inducted}/>
                </Item>
                <Item ui right aligned category search>
                    <Input ui>
                        <Input text bind:value={searchString} placeholder="Search..."/>
                    </Input>
                </Item>
            </Menu>
        {/if}
    </Menu>
{/if}
<!----------------------------------------------------------------------------------------------------->
