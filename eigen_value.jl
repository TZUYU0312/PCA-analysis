using CSV,Statistics
using LinearAlgebra
using DataFrames
using Random
using Plots

#取資料
function data_check(Dim1,Dim2,Dim3,Dim4,Dim5,Dim6) #Dim1[:,1]
    num = [Dim1,Dim2,Dim3,Dim4,Dim5,Dim6] 
    return num
end

function cal_mean_std(data)
    #算平均與標準差
    mean1 = [mean(data[!, col]) for col in names(data)]
    std1 = [std(data[!, col]) for col in names(data)]
    
    return std1,mean1
end


file_path = "dye.csv"
df = CSV.read(file_path, DataFrame)
global n = 6 #決定要降到幾個維度
global class_matrix = df[:,end] #class
global data = df[:,1:6] #dataframe型態的資料
global new_data = [] #陣列型態的data

#將dataframe的數據轉變為陣列型態
for row in eachrow(data)  
    new_data1 = data_check(row[1],row[2],row[3],row[4],row[5],row[6])
    push!(new_data,new_data1)  
end

data_std, data_mean = cal_mean_std(data)

#計算標準化
for i in 1:6
    for j in 1:size(new_data, 1)
        new_data[j][i] = (new_data[j][i] - data_mean[i]) / data_std[i]
    end
end

#將二維陣列變成matrix(5999X6)
global new_std_data = new_data[1]'
for i in 2:size(new_data,1)
    global new_std_data = vcat(new_std_data,new_data[i]')
end

#計算covariance Matrix (6X6)
Conv = (1/5998) * (new_std_data' * new_std_data)

# 計算covariance 的特徵值和特徵向量
eigen_conv = eigen(Conv)

# 取得特徵值與特真與特徵向量
eigen_values = eigen_conv.values
eigen_vector = eigen_conv.vectors

reduce_eigen_values = eigen_values[1:n]

#投影矩陣
global Projection = eigen_vector[1,:]
for i in 2:n
    global Projection = hcat(Projection,eigen_vector[i,:])
end

#計算出最後的轉換函數Y
Y = new_std_data * Projection
println(Y)



# 提取數據的 x 和 y 坐標
x = Y[:, 1]
y = Y[:, 2]
z = Y[:, 3]

# 繪製二維圖
scatter3d(x, y,z, xlabel="X", ylabel="Y",zlabel="Z", title="Graph")
