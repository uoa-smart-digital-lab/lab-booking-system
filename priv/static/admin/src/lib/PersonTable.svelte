<!------------------------------------------------------------------------------------------------------
  All the items in the system
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { query } from 'svelte-apollo';
    import { PERSONALL } from './Graphql.svelte';
    import type { Person, Item } from './Graphql.svelte';
    import { StatusArray, ItemtypeArray } from './Graphql.svelte';
    import { TableButtonTypes, TableColTypes, type TableColumns, type TableDefinition } from './Table/TableTypes';
    import Table from './Table/Table.svelte';
	import { createEventDispatcher } from 'svelte';
    import { beforeUpdate } from 'svelte';

    const dispatch = createEventDispatcher();



    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let searchString : string;               // A string to match against to show only the items being searched for.
    export let sessionid: string;
    export let loggedIn : boolean;                  // Whether a user is logged in or not
    // export let upi : string;                        // Currently logged in user's UPI
    // export let inducted : boolean;                  // Whether to show only items the user is inducted for, or all items.
    // export let availability : boolean;              // Whether to show only items that are currently available for booking.
    // export let qrcode: boolean;
    // export let list: boolean;
    
    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    const columns: TableColumns = [
        {id: "editbutton", title: "", span: 1, type: TableColTypes.BUTTON, sort: false, 
            button:{title:"edit", color:"green", type: TableButtonTypes.EDIT,
                action:(data:any, done:()=>void) =>
                {
                    console.log(data);
                    console.log("Doing Edit");
                    done();
                }
            }, 
            headingButton:{title:"new", color:"blue", type: TableButtonTypes.CREATE,
                action:(data:any, done:()=>void) =>
                {
                    console.log(data);
                    console.log("Doing Create");
                    done();
                }
            }
        },
        {id: "upi", title: "UPI", span: 4, type: TableColTypes.STRING, sort: true},
        {id: "name", title: "Name", span: 4, type: TableColTypes.STRING, sort: true},
        {id: "tokens", title: "Tokens", span: 2, type: TableColTypes.NUMBER, sort: false},
        {id: "status", title: "Status", span: 4, type: TableColTypes.ENUM, sort: true, enum: {enumName:"Status"}},
        {id: "inductions", title: "Inductions", span: 4, type: TableColTypes.LIST, sort: false, list: {
            extractItems: (items:Array<Item>) => items.map(item => item.name)  
        }},
        {id: "inductions_button", title: "", span: 1, type: TableColTypes.BUTTON, sort: false, 
            button:{title:"induct", color:"blue", click:(data:any) => 
                {
                    console.log(data);
                }
            }
        },
        {id: "deletebutton", title: "", span: 1, type: TableColTypes.BUTTON, sort: false, 
            button:{title:"delete", color:"red", type: TableButtonTypes.DELETE,
                action:(data:any, done:()=>void) =>
                {
                    console.log(data);
                    console.log("Doing Delete");
                    done();
                }
            }
        }
    ];

    const enums = { Itemtype: ItemtypeArray, Status: StatusArray }

    const definition: TableDefinition = {
        showHeading: true,
        showBackground: true
    }

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // The GraphQL query structure for login
    const people : any = query(PERSONALL, {
        variables: {},
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    // Check whether the search string is in the name of the item or the details.name of the item. Or if the search string is empty, return true.
    const checkSearch = (person : Person, searchString : string) : boolean => 
        (person.name.toLowerCase().includes(searchString.toLowerCase()) || person.upi.toLowerCase().includes(searchString.toLowerCase()) || (searchString === ""));

    const processRow = (row: object): object => {
        return row;
    }

    beforeUpdate(() => {
		people.refetch();
	});

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
{#if $people.loading}
    Loading...
{:else if $people.error}
    Error: {$people.error.message}
{:else}
    <Table {definition} {columns} {enums} {checkSearch} {processRow} {searchString} data={$people.data.personAll} />
{/if}

<!----------------------------------------------------------------------------------------------------->