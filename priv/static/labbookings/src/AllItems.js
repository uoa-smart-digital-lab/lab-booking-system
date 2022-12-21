import React, { Component } from 'react';
import Item from './Item'
import 'semantic-ui-css/semantic.min.css';
import { Card, Header, Menu, Input, Button } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show all the items
// ----------------------------------------------------------------------------------------------------
class AllItems extends Component
{
    handleChange = (e, { name, value }) => { this.setState({ [name]: value }); }

    constructor(props) {
        super (props);
        this.state = { search: '', loggedin: props.sessionid !== '' };
    }

    detailsname = (details) => {
        return (details.hasOwnProperty("name") ? details.name.toLowerCase() : '');
    }

    ItemCards = (data) => {
        return (
            data.data.itemAll.map(({ name, url, image, bookable, access, details }) => {
                if (bookable && (name.includes(this.state.search.toLowerCase()) || this.detailsname(details).includes(this.state.search.toLowerCase()) || (this.state.search === ""))) {
                    return (<Item name={name} url={url} image={image} bookable={bookable} access={access} details={details} sessionid={this.props.sessionid}/>)
                }
                else { return (<></>); }
            })
        )
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    All items
                </Header>
                <Menu borderless blue fluid widths={2}>
                    <Menu.Item>
                        <Input name='search' icon='search' placeholder='Search for item...' onChange={this.handleChange} />
                    </Menu.Item>
                    <Menu.Item>
                        <Button onClick={this.state.loggedin?this.props.dologout:this.props.dologin}>Log {this.state.loggedin?"out":"in"}</Button>
                    </Menu.Item>
                </Menu>
                <Card.Group centered>
                    <this.ItemCards data={this.props.data} />
                </Card.Group>
            </>
        )
    }
}

export default AllItems;
// ----------------------------------------------------------------------------------------------------
