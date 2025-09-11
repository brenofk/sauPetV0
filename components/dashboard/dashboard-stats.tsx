"use client"

import { useEffect, useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Card, CardContent } from "@/components/ui/card"
import { Heart, Syringe, Bell, Calendar } from "lucide-react"
import { addDays, isBefore } from "date-fns"

interface DashboardStats {
  totalPets: number
  totalVaccines: number
  upcomingVaccines: number
  overdueVaccines: number
}

export function DashboardStats() {
  const [stats, setStats] = useState<DashboardStats>({
    totalPets: 0,
    totalVaccines: 0,
    upcomingVaccines: 0,
    overdueVaccines: 0,
  })
  const [isLoading, setIsLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Fetch pets count
        const { count: petsCount } = await supabase.from("pets").select("*", { count: "exact", head: true })

        // Fetch vaccines data
        const { data: vaccinesData } = await supabase.from("vaccines").select("next_dose_date")

        const today = new Date()
        const thirtyDaysFromNow = addDays(today, 30)

        let upcomingVaccines = 0
        let overdueVaccines = 0

        vaccinesData?.forEach((vaccine) => {
          if (vaccine.next_dose_date) {
            const nextDose = new Date(vaccine.next_dose_date)
            if (isBefore(nextDose, today)) {
              overdueVaccines++
            } else if (isBefore(nextDose, thirtyDaysFromNow)) {
              upcomingVaccines++
            }
          }
        })

        setStats({
          totalPets: petsCount || 0,
          totalVaccines: vaccinesData?.length || 0,
          upcomingVaccines,
          overdueVaccines,
        })
      } catch (error) {
        console.error("Erro ao carregar estatísticas:", error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (isLoading) {
    return (
      <div className="grid grid-cols-2 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card key={i}>
            <CardContent className="p-4">
              <div className="animate-pulse">
                <div className="w-8 h-8 bg-muted rounded-lg mb-2"></div>
                <div className="w-12 h-6 bg-muted rounded mb-1"></div>
                <div className="w-16 h-4 bg-muted rounded"></div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  const statCards = [
    {
      title: "Meus Pets",
      value: stats.totalPets,
      icon: Heart,
      color: "text-primary",
      bgColor: "bg-primary/10",
    },
    {
      title: "Vacinas",
      value: stats.totalVaccines,
      icon: Syringe,
      color: "text-secondary",
      bgColor: "bg-secondary/10",
    },
    {
      title: "Próximas",
      value: stats.upcomingVaccines,
      icon: Calendar,
      color: "text-accent",
      bgColor: "bg-accent/10",
    },
    {
      title: "Atrasadas",
      value: stats.overdueVaccines,
      icon: Bell,
      color: "text-destructive",
      bgColor: "bg-destructive/10",
    },
  ]

  return (
    <div className="grid grid-cols-2 gap-4">
      {statCards.map((stat) => (
        <Card key={stat.title}>
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${stat.bgColor}`}>
                <stat.icon className={`w-5 h-5 ${stat.color}`} />
              </div>
              <div>
                <p className="text-xl font-bold text-foreground">{stat.value}</p>
                <p className="text-xs text-muted-foreground">{stat.title}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
