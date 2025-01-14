<!-- filepath: /e:/backup/LOGIN DESIGN/web_vue/src/components/DepartmentsList.vue -->
<template>
    <div>
      <h1>Departments</h1>
      <button @click="createDepartment">Create Department</button>
      <ul>
        <li v-for="department in departments" :key="department.id">
          {{ department.name }} ({{ department.code }})
          <button @click="editDepartment(department.id)">Edit</button>
          <button @click="deleteDepartment(department.id)">Delete</button>
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        departments: []
      };
    },
    methods: {
      async fetchDepartments() {
        const response = await axios.get('/api/departments');
        this.departments = response.data.data;
      },
      createDepartment() {
        this.$router.push('/departments/create');
      },
      editDepartment(id) {
        this.$router.push(`/departments/${id}/edit`);
      },
      async deleteDepartment(id) {
        await axios.delete(`/api/departments/${id}`);
        this.fetchDepartments();
      }
    },
    mounted() {
      this.fetchDepartments();
    }
  };
  </script>