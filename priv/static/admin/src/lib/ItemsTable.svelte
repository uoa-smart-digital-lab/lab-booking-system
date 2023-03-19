<!------------------------------------------------------------------------------------------------------
  All the items in the system
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { query, mutation } from 'svelte-apollo';
    import { ITEMALL, ITEMCREATE } from './Graphql.svelte';
    import type { Item, ItemDetails, Person, Booking } from './Graphql.svelte';
    import { StatusArray, ItemtypeArray } from './Graphql.svelte';
    import { TableButtonTypes, TableColTypes, type ResultType, type TableColumns, type TableDefinition } from './Table/TableTypes';
    import Table from './Table/Table.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';
	import { createEventDispatcher } from 'svelte';
    import { beforeUpdate } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let searchString : string;               // A string to match against to show only the items being searched for.
    export let loggedIn : boolean;                  // Whether a user is logged in or not
    export let sessionid : string;
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
                action:(data:any, done:(result: ResultType)=>void) =>
                {
                    console.log(data);
                    console.log("Doing Edit");
                    done({ok: data});
                }
            }, 
            headingButton:{title:"new", color:"blue", type: TableButtonTypes.CREATE,
                action:(data:any, done:(result: ResultType)=>void) =>
                {
                    console.log(data);
                    doCreate({ variables: data }) //{ name:data["name"], image:data["image"], url:data["url"], details:data["details"], cost:data["cost"], bookable:data["bookable"], access:data["access"] } })
                    .then((result:any) => {
                        done({ok: result.data.itemCreate});
                    })
                    .catch((error : { graphQLErrors : [{ message : string }]}) => {
                        let errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
                        console.error("Error Creating : " + errorMessage);
                        done({error: errorMessage});
                    });
                }
            }
        },
        {id: "nicename", title: "Name", span: 4, type: TableColTypes.STRING, sort: true},
        {id: "name", title: "ID", span: 4, type: TableColTypes.STRING, sort: true},
        {id: "url", title: "URL", span: 4, type: TableColTypes.LINK, sort: false},
        {id: "image", title: "Image", span: 2, type: TableColTypes.IMAGE, sort: false},
        {id: "bookable", title: "Bookable", span: 2, type: TableColTypes.BOOLEAN, sort: true},
        {id: "cost", title: "Cost", span: 2, type: TableColTypes.NUMBER, sort: false},
        {id: "access", title: "Access", span: 2, type: TableColTypes.ENUM, sort: true, enum: {enumName:"Itemtype"}},
        {id: "bookings", title: "Bookings", span: 1, type: TableColTypes.BUTTON, sort: false, 
            button:{title:"book", color:"blue", click:(data:any) => 
                {
                    bookItem(data);
                }
            }
        },
        {id: "deletebutton", title: "", span: 1, type: TableColTypes.BUTTON, sort: false, 
             button:{title:"delete", color:"red", type: TableButtonTypes.DELETE,
                action:(data:any, done:(result: ResultType)=>void) =>
                {
                    console.log(data);
                    console.log("Doing Delete");
                    done({ok: data});
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
    const items : any = query(ITEMALL, {
        variables: {},
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    // The GraphQL mutation structure for login
    const doCreate = mutation(ITEMCREATE);

    // Get the name from the details if it exists, otherwise return an empty string rather than undefined
    function getname (details : ItemDetails) : string { return(details.name ? details.name : ""); }

    // Check whether the search string is in the name of the item or the details.name of the item. Or if the search string is empty, return true.
    const checkSearch = (item : Item, searchString : string) : boolean => 
        (item.name.includes(searchString.toLowerCase()) || getname(item.details).includes(searchString.toLowerCase()) || (searchString === ""));

    const preProcessRow = (row: object): object => {
        row["nicename"] = row["details"].name;
        return row;
    }

    const postProcessRow = (row: object): object => {
        if (row.hasOwnProperty("details") && row.hasOwnProperty("nicename"))
        {
            row["details"].name = row["nicename"];
        }
        else
        {
            row["details"] = {name:""};
        }
        return row;
    }

    function bookItem (item: any) { dispatch ( 'book', { item : item } ) }

    beforeUpdate(() => {
		items.refetch();
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
{#if $items.loading}
    Loading...
{:else if $items.error}
    Error: {$items.error.message}
{:else}
    <Table {definition} {columns} {enums} {checkSearch} {preProcessRow} {postProcessRow} {searchString} data={$items.data.itemAll} />
{/if}

<!----------------------------------------------------------------------------------------------------->