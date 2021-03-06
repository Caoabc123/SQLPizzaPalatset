﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading.Tasks;
using System.Configuration;
using System.Data;
using TypeLib;
using Dapper;
using Npgsql;

namespace PostgreSQL
{
    public class G3SystemsRepository : IG3SystemsRepository
    {
        private readonly string _connString;

        public G3SystemsRepository()
        {
            // Gets connectionstring from App.config in G3Systems
            _connString = ConfigurationManager.ConnectionStrings["npgsql"].ConnectionString;
        }

        /// <summary>
        /// Open new connection and return it for use
        /// </summary>
        /// <returns></returns>
        private IDbConnection CreateConnection()
        {
            var conn = new NpgsqlConnection(_connString);
            conn.Open();
            return conn;
        }

        public async Task<IEnumerable<ProductOrder>> GetProductOrdersAsync()
        {
            var sqlQuery = "Select * from ProductOrders";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<ProductOrder>(sqlQuery);
            }
        }

        /// <summary>
        /// Get all products
        /// </summary>
        /// <returns></returns>
        public async Task<IEnumerable<Product>> GetProductsAsync()
        {
            var sqlQuery = "Select * From Products";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Product>(sqlQuery);
            }
        }

        /// <summary>
        /// Get all products and return chosen category by matching productType with productTypeID
        /// </summary>
        /// <param name="productType"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Product>> GetProductsAsync(ProductType productType)
        {
            var sqlQuery = "Select * From Products Where ProductTypeID = @ProductTypeID";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Product>(sqlQuery, new { ProductTypeID = productType });
            }
        }

        /// <summary>
        /// Update if product exists Else create new product
        /// </summary>
        /// <param name="product"></param>
        /// <returns></returns>
        public async Task UpdateCreateProduct(Product product)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                    "Proc_ProductSetCreate",
                    new
                    {
                        product.ProductID,
                        product.ProductTypeID,
                        product.ProductName,
                        product.Description,
                        product.PrepTime,
                        product.BasePrice,
                        product.Activated,
                        product.Visible
                    },
                        commandType: CommandType.StoredProcedure
                        );
            }
        }

        /// <summary>
        /// Insert new employee and its employeetypes
        /// </summary>
        /// <param name="employee"></param>
        /// <returns></returns>
        public async Task CreateNewEmployee(List<object> employeeParams)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                        sql: "proc_createnewemployee",
                      param: employeeParams.First(),
                commandType: CommandType.StoredProcedure
                        );
            }
        }

        /// <summary>
        /// Get all employees
        /// </summary>
        /// <returns></returns>
        public async Task<IEnumerable<Employee>> GetEmployeesAsync()
        {
            var sqlQuery = "select * from public.employees";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Employee>(sqlQuery);
            }
        }

        /// <summary>
        /// Update employee properties
        /// </summary>
        /// <param name="employee"></param>
        /// <returns></returns>
        public async Task UpdateEmployeeAsync(Employee employee)
        {
            var sqlQuery = "update employees set username = @username, password = @password, loggedin = false, assignedtostation = @assignedtostation where employeeid = @employeeid";

            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                    sqlQuery,
                    new
                    {
                        employee.EmployeeID,
                        employee.Username,
                        employee.Password,
                        employee.LoggedIn,
                        employee.AssignedToStation
                    });
            }
        }

        /// <summary>
        /// Delete selected employee by id
        /// </summary>
        /// <param name="employee"></param>
        /// <returns></returns>
        public async Task DeleteEmployeeAtId(Employee employee)
        {
            string sqlQuery = "delete from employees where employeeID = @employeeid";

            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(sqlQuery, new { employee.EmployeeID });
            }
        }

        /// <summary>
        /// Get employee by matching username and password
        /// </summary>
        /// <param name="username"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public async Task<Employee> GetEmployeeLoginAsync(string username, string password)
        {
            if (string.IsNullOrWhiteSpace(username + password))
            {
                return null;
            }

            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Employee>(
                       sql: "Proc_GetEmployeeLogin",
                     param: new { p_username = username, p_password = password },
               commandType: CommandType.StoredProcedure)).FirstOrDefault();
            }
        }

        /// <summary>
        /// Get all employeeTypes for employee through ID
        /// </summary>
        /// <param name="employee"></param>
        /// <returns></returns>
        public async Task GetEmployeeTypesByIdAsync(Employee employee)
        {
            var sqlQuery = "select EmployeeTypeID from EmployeesAreEmployeeTypes where EmployeeID = @EmployeeID";

            using (var connection = CreateConnection())
            {
                // Gets all of the users employeeTypes
                var types = (await connection.QueryAsync<EmployeeType>(sqlQuery, new { employee.EmployeeID })).ToList();

                // Add each type to the users List<EmployeeType> Types
                types.ForEach(t => employee.Types.Add(t));
            }
        }

        // Todo sätt summary kommentarer överallt
        // InfoScreen - Hariz
        public async Task<IEnumerable<Order>> GetFinishedOrdersAsync(int id)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Order>(
                      sql: "proc_rightcolumninfoscreen",
                    param: new { buildingid = id },
               commandType: CommandType.StoredProcedure));
            }
        }
        public async Task<IEnumerable<Order>> GetInProcessOrderssAsync(int id)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Order>(
                      sql: "proc_leftcolumninfoscreen",
                    param: new { buildingid = id },
               commandType: CommandType.StoredProcedure)).ToList();
            }
        }

        public async Task CreateProductOrdersAsync(Order order, List<Product> cart)
        {
            var sqlQueryPO = "insert into productorders (productid, orderid) values (@productid, @orderid) returning productorderid;";
            var sqlQueryIngr = "insert into stuffings (productorderid, ingredientid, quantity) values (@productorderid, @ingredientid, @quantity);";

            using (var connection = CreateConnection())
            {
                int productorderid = 0;
                // Wrap order data insert in transaction
                using (var transaction = connection.BeginTransaction())
                {
                    try
                    {
                        foreach (var product in cart)
                        {
                            productorderid = (await connection.QueryAsync<int>(
                                sqlQueryPO, new {
                                    productid = product.ProductID,
                                    orderid = order.OrderID },
                                    transaction: transaction)).Single();

                            if (product.Ingredients.Count > 0)
                            {
                                foreach (var ingredient in product.Ingredients)
                                {
                                    await connection.ExecuteAsync(
                                        sqlQueryIngr, new {
                                            productorderid = productorderid,
                                            ingredientid = ingredient.IngredientID,
                                            quantity = ingredient.Quantity},
                                        transaction: transaction);
                                }
                            }
                        }
                        // Save if all inserts successfull
                        transaction.Commit();
                    }
                    catch
                    {
                        // Undo inserts if error occured
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        // Create new order and return OrderID
        public async Task<int> CreateNewOrderAsync(Order order)
        {
            var sqlQuery = "insert into orders (byterminal) VALUES (@byterminal) returning orderid;";

            using (var connection = CreateConnection())
            {
                var id = (await connection.QueryAsync<int>(sqlQuery, new { byterminal = order.ByTerminal })).Single();

                return id;
            }
        }

        // Update order by OrderID
        public async Task UpdateOrderStatusAsync(Order order)
        {
            var sqlQuery = "update orders set paid = @paid, pickedup = @pickedup, canceled = @canceled, returned = @returned where orderid = @orderid";

            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                        sql: sqlQuery,
                      param: new
                      {
                          orderid = order.OrderID,
                          paid = order.Paid,
                          order.Canceled,
                          order.PickedUp,
                          order.Returned
                      });
            }
        }

        public async Task<IEnumerable<Ingredient>> GetIngredients()
        {
            var sqlQuery = "select * from ingredients;";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Ingredient>(sqlQuery);
            }
        }

        public async Task UpdateCreateIngredient(Ingredient ingredient)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                    sql: "Proc_IngredientSetCreate",
                    param: new
                    {
                        ingredient.IngredientID,
                        ingredient.IngredientName,
                        ingredient.Price,
                        ingredient.Activated,
                        ingredient.Visible
                    },
                    commandType: CommandType.StoredProcedure);
            }
        }


        // Ingredients
        public async Task<IEnumerable<Ingredient>> GetHaveIngredientsAsync(int id)
        {
            var sqlQuery = @"
                     select * from ingredients as i
			         join producthaveingredients as phi
			         on phi.ingredientid = i.ingredientid
			         where phi.productid = @productid;";

            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Ingredient>(
                        sql: sqlQuery,
                      param: new { @productid = id }));
            }
        }

        public async Task<IEnumerable<Ingredient>> GetCanHaveIngredientsAsync(int id)
        {
            var sqlQuery = @"
                     select * from ingredients as i
			         join productcanhaveingredients as phi
			         on phi.ingredientid = i.ingredientid
			         where phi.productid = @productid;";

            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Ingredient>(
                        sql: sqlQuery,
                      param: new { @productid = id }));
            }
        }

        // Cashier  - Hariz
        //Sätter picked up på en order.
        public async Task SetOrderPickedUpToAsync(int id, bool pickbit)
        {
            ////Konvertera bool till en int - - Inkapsla! Denna kod upprepas.
            //int bit_from_bool;
            //if (pickbit == true) bit_from_bool = 1;
            //else bit_from_bool = 0;

            using (var connection = CreateConnection())
            {
                await connection.QueryAsync<Order>(
                      sql: "setpickedup",
                    param: new { porderid = id, ppickedup = pickbit },
               commandType: CommandType.StoredProcedure);
            }   //Return signal of successs?


        }

        // Baker - Hariz
        public async Task<IEnumerable<Workload>> GetOpenPOAsync(int pBuildingid)
        {
            //Vänstra listan på baker
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Workload>(
                       sql: "Proc_OpenOrders",
                     param: new { BuildingID = pBuildingid },
                commandType: CommandType.StoredProcedure));
            }

        }

        /// <summary>
        /// Returns all the stuffings for a Product Order
        /// </summary>
        /// <param name="pProductOrderid"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Ingredient>> GetStuffingsAsync(int pProductOrderid)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Ingredient>(
                       sql: "Proc_GetStuffings",
                     param: new { ProductOrderID = pProductOrderid },
                commandType: CommandType.StoredProcedure));
            }
        }

        //Använd stationid =0 för att "låsa upp" productorder.
        public async Task SetLockOnkPOAsync(int pProductOrderid, int pStationid)
        {
            using (var connection = CreateConnection())
            {
                await connection.QueryAsync<Order>(
                      sql: "Proc_SetLockedByStation",
                    param: new { ProductOrderID = pProductOrderid, StationID = pStationid },
               commandType: CommandType.StoredProcedure);
            }
        }

        /// <summary>
        /// Marks a Product Order as Processed
        /// </summary>
        /// <param name="pProductOrderid"></param>
        /// <param name="pProcessed"></param>
        /// <returns></returns>
        public async Task SetProcessedOnkPOAsync(int pProductOrderid, bool pProcessed)
        {

            int bit_from_bool;
            if (pProcessed == true) bit_from_bool = 1;
            else bit_from_bool = 0;

            using (var connection = CreateConnection())
            {
                await connection.QueryAsync<Order>(
                      sql: "Proc_SetProcessed",
                    param: new { ProductOrderID = pProductOrderid, Processed = bit_from_bool },
               commandType: CommandType.StoredProcedure);
            }

        }

        public async Task<ProductOrder> GetLockedPOByStation(int pStationid)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<ProductOrder>(
                       sql: "proc_polockedbystation",
                     param: new { @stationid = pStationid },
                commandType: CommandType.StoredProcedure)).FirstOrDefault();
            }
        }

        //Gives only one station
        public async Task<Station> GetAssignedStation(int pEmployeeid)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Station>(
                       sql: "proc_getassignedstation",
                     param: new { @employeeid = pEmployeeid },
                commandType: CommandType.StoredProcedure)).FirstOrDefault();
            }
        }

        /// <summary>
        /// Returns the details for a ProductOrder record.
        /// </summary>
        /// <param name="pProductOrderId"></param>
        /// <returns></returns>
        public async Task<Product> GetProductInfoFromPO(int pProductOrderId)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Product>(
                       sql: "Proc_GetProductInfoFromPO",
                     param: new { @ProductOrderID = pProductOrderId },
                commandType: CommandType.StoredProcedure)).FirstOrDefault();
            }
        }

        public async Task<IEnumerable<Station>> GetPossibleStationsForEmployee(int pEmployeeid)
        {
            using (var connection = CreateConnection())
            {
                return (await connection.QueryAsync<Station>(
                       sql: "Proc_GetPossibleStationsForEmployee",
                     param: new { @EmployeeID = pEmployeeid },
                commandType: CommandType.StoredProcedure));
            }
        }

        public async Task AssignStationAsync(int pEmployeeid, int pStationid)
        {
            using (var connection = CreateConnection())
            {
                await connection.QueryAsync<Order>(
                      sql: "Proc_SetEmployeeToStation",
                    param: new { @EmployeeID = pEmployeeid, @Stationid = pStationid },
               commandType: CommandType.StoredProcedure);
            }
        }

        public async Task UpdateEmployeeStatusAsync(Employee employee)
        {
            var sqlQuery = "update employees set loggedin = false, assignedtostation = @assignedtostation where employeeid = @employeeid";

            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                    sqlQuery,
                    new
                    {
                        employee.EmployeeID,
                        employee.LoggedIn,
                        employee.AssignedToStation
                    });
            }
        }

        public async Task<IEnumerable<Order>> GetOrdersAsync()
        {
            var sqlQuery = "select * from orders";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Order>(sqlQuery);
            }
        }

        public async Task AddNewProductAsync(Product product)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                      sql: "Proc_AddProduct",
                    param: new { product.ProductName, product.ProductTypeID, product.BasePrice, product.Description },
               commandType: CommandType.StoredProcedure);
            }
        }

        public async Task AddNewIngredientAsync(Ingredient ingredient)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                      sql: "Proc_AddIngredient",
                    param: new { Name = ingredient.IngredientName, Price = ingredient.Price },
               commandType: CommandType.StoredProcedure);
            }
        }

        public async Task AddNewIngredientToProductAsync(Product product)
        {
            using (var connection = CreateConnection())
            {
                foreach (var ingredient in product.Ingredients)
                {
                    await connection.ExecuteAsync(
                          sql: "Proc_AddIngredientToProduct",
                        param: new { product.ProductID, ingredient.IngredientID },
                   commandType: CommandType.StoredProcedure);
                }
            }
        }

        /// <summary>
        /// Returns all the ingredients in the entire database
        /// </summary>
        /// <returns></returns>
        public async Task<IEnumerable<Ingredient>> GetAllIngredientsAsync()
        {
            var sqlQuery = "select * from ingredients";

            using (var connection = CreateConnection())
            {
                return await connection.QueryAsync<Ingredient>(sqlQuery);
            }
        }

        /// <summary>
        /// Returns the Ingredients that are allowed by a Product Type
        /// </summary>
        /// <param name="ProductTypeid"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Ingredient>> GetAllowedIngredientsByPTypeAsync(ProductType type)
        {
            
                var sqlQuery = @"SELECT * FROM Ingredients    
                                WHERE IngredientID in
                                (SELECT IngredientID
                                FROM TypeCanHaveIngredients
                                WHERE ProductTypeID = @ProductTypeID )";

                using (var connection = CreateConnection())
                {
                    return await connection.QueryAsync<Ingredient>(sqlQuery);
                }


        }

        public async Task DeleteIngredientsByProductId(Product product)
        {
            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(
                      sql: "Proc_DeleteIngredientsForProduct",
                    param: new { product.ProductID },
               commandType: CommandType.StoredProcedure);
            }
        }
    }
}
