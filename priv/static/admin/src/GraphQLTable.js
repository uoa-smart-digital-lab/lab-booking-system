// ----------------------------------------------------------------------------------------------------
// GraphQL Table Version 2
// A tool to make working with GraphQL data easier in an administration context
// ----------------------------------------------------------------------------------------------------


import React, { useState, useEffect } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Button, Table, Header, Icon, Message, Modal, Grid, Divider, Form } from 'semantic-ui-react'
import GraphQL from './graphql';
import './App.css';
import {
    ApolloProvider,
    useLazyQuery,
    useMutation
  } from "@apollo/client";
import { ExecutableDefinitionsRule } from 'graphql';


// ----------------------------------------------------------------------------------------------------
// Main Function
// ----------------------------------------------------------------------------------------------------
export default function GraphqQlTable(props) { return (<ApolloProvider client={GraphQL.client}> <View props={props}/> </ApolloProvider>); }
// ----------------------------------------------------------------------------------------------------


// ----------------------------------------------------------------------------------------------------
// Show the table
// ----------------------------------------------------------------------------------------------------
function View({props})
{
    // ------------------------------------------------------------------------------------------------
    // A place for temporary values
    // ------------------------------------------------------------------------------------------------
    var storage = 
    {
        newDetails: {}
    }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    const handleClick = (action, data) => {
        switch (action) {
            case "delete" : state.set("currentDetails", data);    state.set("currentState", state.states.deleting);   break;
            case "edit"   : state.set("currentDetails", data);    state.set("currentState", state.states.editing);    break;
            case "add"    : state.set("currentState", state.states.adding);   break;
            default: break;
        }
    };
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Set up the state variables.  Use state.set("Variable Name", New Value) to set.  Whenever it
    // is called, the page is refreshed.
    // ------------------------------------------------------------------------------------------------
    const [state, setState] = useState({
		sessionid: props.sessionid,
        states: {main: 0, deleting: 1, editing: 2, adding: 3, error: 4, done: 5},
        currentState: 0,
        currentDetails: {},
        errorMessage: "",
        columns: {},
        subfields: {},

        set: (name, value) => { setState( previousState => { return { ...previousState, [name]: value }} ); },
        set_quiet: (name, value) => { state[name] = value }
	});
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Anything you want to run when something changes, and on first load.  Add variables etc to array
    // to define them as requiring a reload when they change.
    // ------------------------------------------------------------------------------------------------
    useEffect(() =>
	{	
        // Add the buttons columns to the begining and end of the columns array
        let newcolumns = [];
        if (props.details.queries.hasOwnProperty("delete")) {
            newcolumns.push({title: "", width: 1, name: "", 
                content: (e) => {return (<Button basic icon color='red' onClick={()=> {handleClick("delete", e)}}> <Icon name='close'/></Button>)}});
        }
        props.details.columns.forEach((col) => {
            if (col.type ==="table")
            {
                LoadSubQuery({sessionid: state.sessionid, query: props.details.subqueries[col.name], name: col.name, field: col.table[1]})
                .then((data) => {
                    if (! state.subfields.hasOwnProperty(col.table[0])) state.subfields[col.table[0]] = {};
                    state.subfields[col.table[0]][col.table[1]] = data; state.set("subfields", state.subfields)
                })
            }
            newcolumns.push(col)
        });
        newcolumns.push ({title: "", width: 1, name: "", 
            content: (e) => { 
                if (props.details.queries.hasOwnProperty("update")) {
                    return (<Button basic icon color='green' onClick={() => {handleClick("edit", e)}}> <Icon name='edit'/></Button>)
                } else {
                    return (<div></div>);
                }    
            },
            header: (e) => {
                if (props.details.queries.hasOwnProperty("create")) {
                    return (<Button basic icon color='blue' onClick={()=> {handleClick("add", e)}}> <Icon name='plus'/></Button>)
                } else {
                    return (<div></div>);
                }  
            }
        });

        state.set("columns", newcolumns);
        // Load the main data
        LoadMain();

	}, []);
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Various function as required by the UX
    // ------------------------------------------------------------------------------------------------
    const cancel = () => {
        state.set("currentState", state.states.main);
    }
    const deleteItem = () => {
        DoDelete();
    }
    const changeItem = (e) => {
        DoUpdate();
    }
    const addItem = () => {
        DoCreate();
    }
    const refresh = () => {
        storage.newDetails = {};
        state.set("currentState", state.states.main);
    }

    const CollateData = (newDetails) => {
        props.details.columns.forEach((col) => {
            // Copy over any indexes to make sure they are present.
            if (col.index)
            {
                if (col.type === "table")
                {
                    if (state.currentDetails.hasOwnProperty(col.table[0]) && (state.currentDetails[col.table[0]] !== null)) 
                    {
                        if (state.currentDetails[col.table[0]].hasOwnProperty(col.table[1]) && (state.currentDetails[col.table[0]][col.table[1]] !== null))
                        {
                            if (!newDetails.hasOwnProperty(col.name))
                                newDetails[col.name] = state.currentDetails[col.table[0]][col.table[1]]; 
                        }
                    }
                 }
                else
                {
                    if (state.currentDetails.hasOwnProperty(col.name) && (state.currentDetails[col.name] != null) && !newDetails.hasOwnProperty(col.name))
                        newDetails[col.name] = state.currentDetails[col.name];
                }
            }

            // Convert anything to appropriate formats if needs be
            if (newDetails.hasOwnProperty(col.name))
            {
                switch (col.type) {
                    case "number":
                        newDetails[col.name] = parseFloat(newDetails[col.name]===""?"0":newDetails[col.name]);
                        break;
                    case "boolean":
                        newDetails[col.name] = newDetails[col.name]==="true"
                        break;
                    case "json":
                        newDetails[col.name] = JSON.parse(newDetails[col.name]===""?"{}":newDetails[col.name]);
                        break;                        
                    case "table":
                        break;
                    case "enum":
                        break;
                    default:
                        break;
                }
            }
        });
        return newDetails;
    }


    const [update] = useMutation(props.details.queries.update);
    let DoUpdate = () =>
	{		
        let newDetails = CollateData(storage.newDetails);
		update({variables: newDetails, context: { headers : { sessionid : state.sessionid } }})
		.then(() => {state.set("currentState", state.states.done); LoadMain();})
		.catch(error => {console.log(error); state.set("errorMessage", JSON.stringify(error.message)); state.set("currentState", state.states.error); LoadMain(); });
	};

    const [create] = useMutation(props.details.queries.create);
    let DoCreate = () =>
    {		
        let newDetails = CollateData(storage.newDetails);
		create({variables: newDetails, context: { headers : { sessionid : state.sessionid } }})
		.then(() => {state.set("currentState", state.states.done); LoadMain();})
		.catch(error => {console.log(error); state.set("errorMessage", JSON.stringify(error.message)); state.set("currentState", state.states.error); LoadMain(); });
	};

    const [delete_cmd] = useMutation(props.details.queries.delete);
    let DoDelete = () =>
    {		
        let newDetails = CollateData(storage.newDetails);
        console.log(newDetails);
		delete_cmd({variables: newDetails, context: { headers : { sessionid : state.sessionid } }})
		.then(() => {state.set("currentState", state.states.done); LoadMain();})
		.catch(error => {console.log(error); state.set("errorMessage", JSON.stringify(error.message)); state.set("currentState", state.states.error); LoadMain(); });
	};
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Set newDetails from input from a form (usually)
    // ------------------------------------------------------------------------------------------------
    const handleChange = (e, { name, value }) => { storage.newDetails[name] = value; }
    const clearDetails = () => { storage.newDetails = {}; }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Set up the main query
    // ------------------------------------------------------------------------------------------------
    const [LoadMain, { loading, error, data }] = useLazyQuery(props.details.queries.main, {
        context : { headers : { sessionid : state.sessionid } },
        fetchPolicy: 'network-only'
    });
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // What to do on loading or an error.  Can be used to call other functions or show something.
    // ------------------------------------------------------------------------------------------------
    if (loading) return (<div></div>);
    if (error)   { state.set_quiet("errorMessage", JSON.stringify(error)); state.set("currentState", state.states.error); }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // The main display area / UX
    // ------------------------------------------------------------------------------------------------
    if (data) {
        switch (state.currentState) {
            case state.states.main:
                return (
                    <>
                        <Header textAlign='center' centered color='blue' block>
                            <h3>{props.details.title}</h3>
                            <Message info> {props.details.description} </Message>
                        </Header>
                        <Table unstackable celled>
                            <Table.Header fullWidth> <TableHeader /> </Table.Header>
                            <Table.Body> <TableContent content={data[Object.keys(data)[0]]} /> </Table.Body>
                            <Table.Footer fullWidth> </Table.Footer>
                        </Table>
                    </>
                );
            case state.states.deleting:
                return ( <DeleteEntry cancel={cancel} doit={deleteItem} title={state.currentDetails.name}/> )
            case state.states.editing:
                return ( <EditEntry cancel={cancel} doit={changeItem} title={state.currentDetails.name} entry={state.currentDetails} handleChange={handleChange} clearDetails={clearDetails}/> )
            case state.states.adding:
                return ( <AddEntry cancel={cancel} doit={addItem} handleChange={handleChange} clearDetails={clearDetails}/> )
            case state.states.done:
                return ( <Done doit={refresh}/> );
            default:
                return ( <Error doit={refresh} message={"Error : " + state.errorMessage}/> );
        }
    }
    else {
        return (<div></div>);
    }
    // ------------------------------------------------------------------------------------------------

    // ------------------------------------------------------------------------------------------------
    // Additional UX Elements
    // ------------------------------------------------------------------------------------------------
    function TableHeader() { return ( <Table.Row><TableHeaderLineContent /></Table.Row> ); }
    // ------------------------------------------------------------------------------------------------
    function TableHeaderLineContent() { return ( state.columns.map((col) => ( col.nocol?"":<Table.HeaderCell textAlign='center' width={col.width}>{col.hasOwnProperty("header")?col.header(1):col.title}</Table.HeaderCell> )))}
    // ------------------------------------------------------------------------------------------------
    function TableContent({content}) { return ( content.map((entry) => ( <Table.Row><LineContent id={entry.upi} entry={entry} /></Table.Row> )))}
    // ------------------------------------------------------------------------------------------------
    function LineContent({entry}) { 
        const col_content = (col) => {
            let col_content = "";
            if (col.type === "table")
            {
                if (entry.hasOwnProperty(col.table[0]) && (entry[col.table[0]] !== null)) 
                {
                    if (entry[col.table[0]].hasOwnProperty(col.table[1]) && (entry[col.table[0]][col.table[1]] !== null))
                    {
                        col_content = entry[col.table[0]][col.table[1]];
                    }
                }
            }
            else if (col.type === "json")
            {
                if (entry.hasOwnProperty(col.name)) {
                    col_content = JSON.stringify(entry[col.name]);
                }               
            }
            else if (col.type === "boolean")
            {
                if (entry.hasOwnProperty(col.name)) {
                    col_content = entry[col.name] ? "true" : "false";
                }               
            }
            else {
                if (entry.hasOwnProperty(col.name)) {
                    col_content = entry[col.name];
                }
            }
            return col_content;
        }
    
        return ( 
            state.columns.map((col) => ( 
                col.nocol?"":<Table.Cell textAlign='center' width={col.width}>
                    {col.hasOwnProperty("content")?col.content(entry):col_content(col)}
                </Table.Cell> 
            )
        ))
    }
    // ------------------------------------------------------------------------------------------------
    function Done({doit}) { return (
        <Modal open={true} size='mini' >
            <Modal.Content>
            <Header as='h4' textAlign='center'>
                <span>All done and dusted</span>
            </Header>
            </Modal.Content>
            <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
            <Grid columns='one'>
                <Grid.Row>
                    <Grid.Column> <Button fluid basic color='green' onClick={doit}>OK</Button> </Grid.Column>
                </Grid.Row>
            </Grid>
            </Modal.Actions>
        </Modal>
    )}
    // ------------------------------------------------------------------------------------------------
    function Error({doit, message}) { return (
        <Modal open={true} size='mini' >
            <Modal.Content>
            <Header as='h4' textAlign='center'>
                <span>There was an error</span>
            </Header>
            </Modal.Content>
            <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
            <Grid columns='one'>
                <Grid.Row>
                    <Grid.Column> <span>{message}</span> </Grid.Column>
                </Grid.Row>
                <Grid.Row>
                    <Grid.Column> <Button fluid basic color='green' onClick={doit}>OK</Button> </Grid.Column>
                </Grid.Row>
            </Grid>
            </Modal.Actions>
        </Modal>
    )}
    // ------------------------------------------------------------------------------------------------
    function EditEntry({entry, title, cancel, doit, handleChange, clearDetails}) {
        return (
            <Modal open={true} size='mini' >
                <Modal.Content>
                <Header as='h4' textAlign='center'>
                    <span>Edit {title}</span>
                </Header>
                <Divider />
                <Grid columns='one'>
                    <Grid.Row>
                    <Grid.Column>
                        <Form>
                            <FormFieldsEdit entry={entry} handleChange={handleChange} clearDetails={clearDetails}/>
                        </Form>
                    </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Content>
                <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
                <Grid columns='two'>
                    <Grid.Row>
                        <Grid.Column> <Button fluid basic color='green' onClick={cancel}>Cancel</Button> </Grid.Column>
                        <Grid.Column> <Button fluid basic color='blue'onClick={doit}>Modify</Button> </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Actions>
            </Modal>
        )
    }
    // ------------------------------------------------------------------------------------------------
    function FormFieldsEdit({entry, handleChange, clearDetails}) {
        clearDetails();
        let inputs = [];
        state.columns.forEach((col) => {
            if (col.name !== "")
            {
                if ((col.type === "table") && (col.editable))
                {
                    let the_details = state.subfields[col.table[0]][col.table[1]];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    let default_value = "";
                    if (entry.hasOwnProperty(col.table[0]) && (entry[col.table[0]] !== null)) 
                    {
                        if (entry[col.table[0]].hasOwnProperty(col.table[1]) && (entry[col.table[0]][col.table[1]] !== null))
                        {
                            default_value = entry[col.table[0]][col.table[1]];
                        }
                    }
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    name={col.name}
                                    label={col.title}
                                    defaultValue={default_value}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else if ((col.type === "enum") && (col.editable))
                {
                    let the_details = props.details[col.enum];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    name={col.name}
                                    label={col.title}
                                    defaultValue={entry[col.name]}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else if ((col.type === "json") && (col.editable))
                {
                    inputs.push(
                        <Form.Field>
                            <Form.Input label={col.title} placeholder={col.title} defaultValue={entry[col.name]} name={col.name} onChange={handleChange} type="text" />
                        </Form.Field>
                    )
                }
                else if ((col.type === "boolean") && (col.editable))
                {
                    let the_details = ["true", "false"];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    name={col.name}
                                    label={col.title}
                                    defaultValue={(entry[col.name]===true)?"true":"false"}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else 
                {
                    inputs.push(
                        <Form.Field>
                            <Form.Input readOnly={!col.editable} label={col.title} placeholder={col.title} name={col.name} defaultValue={entry[col.name]} onChange={handleChange} type={col.type==="password"?"password":"text"} />
                        </Form.Field>
                    )
                }
            }
        })
        return ( inputs );
    }
    // ------------------------------------------------------------------------------------------------
    function AddEntry({title, cancel, doit, handleChange, clearDetails}) {
        return (
            <Modal open={true} size='mini' >
                <Modal.Content>
                <Header as='h4' textAlign='center'>
                    <span>Edit {title}</span>
                </Header>
                <Divider />
                <Grid columns='one'>
                    <Grid.Row>
                    <Grid.Column>
                        <Form>
                            <FormFieldsCreate handleChange={handleChange} clearDetails={clearDetails}/>
                        </Form>
                    </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Content>
                <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
                <Grid columns='two'>
                    <Grid.Row>
                        <Grid.Column> <Button fluid basic color='green' onClick={cancel}>Cancel</Button> </Grid.Column>
                        <Grid.Column> <Button fluid basic color='blue'onClick={doit}>Add</Button> </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Actions>
            </Modal>
        )
    }
    // ------------------------------------------------------------------------------------------------
    function FormFieldsCreate({handleChange, clearDetails}) {
        clearDetails();
        let inputs = [];
        state.columns.forEach((col) => {
            if (col.name !== "")
            {
                if (col.type === "table")
                {
                    let the_details = state.subfields[col.table[0]][col.table[1]];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    placeholder={col.title} 
                                    name={col.name}
                                    label={col.title}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else if (col.type === "enum")
                {
                    let the_details = props.details[col.enum];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    placeholder={col.title} 
                                    name={col.name}
                                    label={col.title}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else if (col.type === "json")
                {
                    inputs.push(
                        <Form.Field>
                            <Form.Input label={col.title} placeholder={col.title} name={col.name} onChange={handleChange} type="text" />
                        </Form.Field>
                    )
                }
                else if (col.type === "boolean")
                {
                    let the_details = ["true", "false"];
                    let drop_menu = the_details.map((item) => {return ({key: item, text: item, value: item})});
                    inputs.push(
                        <Form.Field>
                              <Form.Dropdown
                                    name={col.name}
                                    label={col.title}
                                    fluid
                                    selection
                                    options={drop_menu}
                                    onChange={handleChange}
                                />
                        </Form.Field>
                    )
                }
                else
                {
                    inputs.push(
                        <Form.Field>
                            <Form.Input label={col.title} placeholder={col.title} name={col.name} onChange={handleChange} type={col.type==="password"?"password":"text"} />
                        </Form.Field>
                    )
                }
            }
        })
        return ( inputs );
    }
    // ------------------------------------------------------------------------------------------------
    function DeleteEntry({cancel, title, doit}) {
        return (
            <Modal open={true} size='tiny' >
                <Modal.Content>
                    <Header as='h4' textAlign='center'>
                        <span>Delete {title}</span>
                    </Header>
                    <Divider />
                    <Grid columns='one'>
                        <Grid.Row>
                            <Grid.Column centered>
                                Are you certain you want to delete this entry.  There is NO undo!
                            </Grid.Column>
                        </Grid.Row>
                    </Grid>
                </Modal.Content>
                <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
                    <Grid columns='two'>
                        <Grid.Row>
                            <Grid.Column> <Button fluid basic color='green' onClick={cancel}>Cancel</Button> </Grid.Column>
                            <Grid.Column> <Button fluid basic color='red'onClick={doit}>Delete</Button> </Grid.Column>
                        </Grid.Row>
                    </Grid>
                </Modal.Actions>
            </Modal>
        )
    }
    // ------------------------------------------------------------------------------------------------
}

// ------------------------------------------------------------------------------------------------
// Set up the sub query
// ------------------------------------------------------------------------------------------------
function LoadSubQuery({query, sessionid}) 
{
    return new Promise ((resolve, reject) => {
        let headers = {sessionid:sessionid};
        let body = query.loc.source.body;
        let uri = GraphQL.client.link.options.uri;

        // We are assuming that the query is a simple one of the form "query { command { field } }"
         GraphQL.fetch({uri: uri, headers: headers, body: body})
        .then ((result) => {
            let items = [];
            let command = Object.keys(result.data)[0];
            result.data[command].forEach((item) => {
                let field = Object.keys(item)[0];
                items.push(item[field]);
            })
            resolve(items);
        })
        .catch ((err) => {
            reject(err);
        });
    });
}
// ------------------------------------------------------------------------------------------------
